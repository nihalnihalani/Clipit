import SwiftUI
import AppKit
import ImageIO

struct ClippyLoadingView: View {
    let isLoading: Bool
    let message: String
    let animationResetID: UUID

    init(isLoading: Bool = false, message: String = "Clippy is ready to help!", animationResetID: UUID = UUID()) {
        self.isLoading = isLoading
        self.message = message
        self.animationResetID = animationResetID
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            AnimatedClippy(isAnimating: isLoading, resetID: animationResetID)
                .frame(width: 77, height: 77)
                .background(Color.clear)
                .accessibilityHidden(true)
            
            // Thinking cloud when processing
            if isLoading {
                ThinkingCloud()
                    .frame(width: 51, height: 51)
                    .offset(x: 13, y: -10)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(width: 128, height: 128)
        .accessibilityLabel(Text(accessibilityDescription))
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isLoading)
    }

    private var accessibilityDescription: String {
        isLoading
            ? "Clippy is busy helping. \(message)"
            : "Clippy is ready. \(message)"
    }
}

private struct AnimatedClippy: View {
    let isAnimating: Bool
    let resetID: UUID
    
    var body: some View {
        AnimatedClippyPlayer(isProcessing: isAnimating, resetID: resetID)
    }
}

// GIF frame-based animated Clippy view
private struct AnimatedClippyPlayer: NSViewRepresentable {
    let isProcessing: Bool
    let resetID: UUID
    
    // Frame animation settings
    private let introStartFrame: Int = 0
    private let introEndFrame: Int = 299  // 1-300 (0-indexed: 0-299)
    private let loopStartFrame: Int = 132  // Frame 133 (0-indexed: 132)
    private let loopEndFrame: Int = 299    // Frame 300 (0-indexed: 299)
    
    func makeNSView(context: Context) -> NSView {
        let containerView = NSView()
        containerView.wantsLayer = true
        containerView.layer?.backgroundColor = NSColor.clear.cgColor
        
        // Get the GIF from bundle - try Clippy first, fallback to CuteDog if not found yet
        var gifImage = NSImage(named: "Clippy")
        if gifImage == nil {
            gifImage = NSImage(named: "CuteDog")
            if gifImage != nil {
                print("ℹ️ Using CuteDog.gif as fallback - please replace with Clippy.gif")
            }
        }
        
        guard let gif = gifImage else {
            print("⚠️ Clippy.gif not found in bundle (see CLIPPY_ASSETS_INSTRUCTIONS.md)")
            return createFallbackView()
        }
        
        print("🎬 [ClippyLoadingView] Found GIF image")
        
        // Extract frames from GIF
        guard let frames = extractFramesFromGIF(gif) else {
            print("⚠️ Could not extract frames from GIF")
            return createFallbackView()
        }
        
        print("🎬 [ClippyLoadingView] Extracted \(frames.count) frames from GIF")
        
        // Create NSImageView for frame-by-frame playback
        let imageView = NSImageView()
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.wantsLayer = true
        imageView.layer?.backgroundColor = NSColor.clear.cgColor
        
        containerView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        // Store frame data in coordinator
        context.coordinator.imageView = imageView
        context.coordinator.frames = frames
        context.coordinator.introStartFrame = introStartFrame
        context.coordinator.introEndFrame = introEndFrame
        context.coordinator.loopStartFrame = loopStartFrame
        context.coordinator.loopEndFrame = loopEndFrame
        
        // Start animation
        Task {
            await context.coordinator.startAnimation(resetID: resetID)
        }
        
        print("🎬 [ClippyLoadingView] Starting frame animation")
        
        return containerView
    }
    
    private func extractFramesFromGIF(_ gifImage: NSImage) -> [NSImage]? {
        // Get the GIF data from bundle - try Clippy first, fallback to CuteDog
        var gifURL = Bundle.main.url(forResource: "Clippy", withExtension: "gif")
        if gifURL == nil {
            gifURL = Bundle.main.url(forResource: "CuteDog", withExtension: "gif")
        }
        
        guard let url = gifURL,
              let gifData = try? Data(contentsOf: url) else {
            print("⚠️ Could not load GIF data")
            return nil
        }
        
        guard let cgImageSource = CGImageSourceCreateWithData(gifData as CFData, nil) else {
            print("⚠️ Could not create image source from GIF data")
            return nil
        }
        
        let frameCount = CGImageSourceGetCount(cgImageSource)
        var frames: [NSImage] = []
        
        print("🎬 [ClippyLoadingView] Extracting \(frameCount) frames from GIF")
        
        for i in 0..<frameCount {
            guard let cgImage = CGImageSourceCreateImageAtIndex(cgImageSource, i, nil) else {
                print("⚠️ Could not extract frame \(i)")
                continue
            }
            
            let nsImage = NSImage(cgImage: cgImage, size: gifImage.size)
            frames.append(nsImage)
        }
        
        print("🎬 [ClippyLoadingView] Successfully extracted \(frames.count) frames")
        return frames.isEmpty ? nil : frames
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        // Update animation speed based on processing state
        Task {
            await context.coordinator.updateAnimationSpeed(isProcessing: isProcessing)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    class Coordinator: NSObject {
        var imageView: NSImageView?
        var frames: [NSImage] = []
        var currentResetID: UUID = UUID()
        var animationTimer: Timer?
        var currentFrame: Int = 0
        var isPlayingIntro: Bool = true
        var isPlayingReverse: Bool = false
        var isProcessing: Bool = false
        
        // Frame settings
        var introStartFrame: Int = 0
        var introEndFrame: Int = 299
        var loopStartFrame: Int = 132
        var loopEndFrame: Int = 299
        
        // Animation speed settings
        let normalFPS: TimeInterval = 1.0 / 30.0  // 30 FPS
        let processingFPS: TimeInterval = 1.0 / 60.0  // 60 FPS (2x faster)
        
        override init() {
            super.init()
        }
        
        deinit {
            DispatchQueue.main.async { [weak animationTimer] in
                animationTimer?.invalidate()
            }
        }
        
        @MainActor
        func startAnimation(resetID: UUID) async {
            currentResetID = resetID
            stopAnimation()
            
            guard !frames.isEmpty else {
                print("⚠️ No frames to animate")
                return
            }
            
            print("🎬 [ClippyLoadingView] Starting animation with \(frames.count) frames")
            print("🎬 [ClippyLoadingView] Intro: frames \(introStartFrame)-\(introEndFrame)")
            print("🎬 [ClippyLoadingView] Loop: frames \(loopStartFrame)-\(loopEndFrame) (forward & reverse)")
            
            isPlayingIntro = true
            isPlayingReverse = false
            currentFrame = introStartFrame
            
            // Start with appropriate FPS
            let frameRate = isProcessing ? processingFPS : normalFPS
            print("🎬 [ClippyLoadingView] Animation speed: \(isProcessing ? "FAST (processing)" : "NORMAL")")
            animationTimer = Timer.scheduledTimer(withTimeInterval: frameRate, repeats: true) { [weak self] _ in
                self?.advanceFrame()
            }
        }
        
        @MainActor
        func updateAnimationSpeed(isProcessing: Bool) {
            guard self.isProcessing != isProcessing else { return }
            
            self.isProcessing = isProcessing
            
            // Restart timer with new speed
            stopAnimation()
            let frameRate = isProcessing ? processingFPS : normalFPS
            print("🎬 [ClippyLoadingView] Animation speed changed to: \(isProcessing ? "FAST (processing)" : "NORMAL")")
            animationTimer = Timer.scheduledTimer(withTimeInterval: frameRate, repeats: true) { [weak self] _ in
                self?.advanceFrame()
            }
        }
        
        @MainActor
        func stopAnimation() {
            animationTimer?.invalidate()
            animationTimer = nil
        }
        
        @MainActor
        private func advanceFrame() {
            guard currentFrame < frames.count else { return }
            
            // Display current frame
            imageView?.image = frames[currentFrame]
            
            if isPlayingIntro {
                // Playing intro (frames 1-300 forward)
                if currentFrame >= introEndFrame {
                    // Intro finished, switch to reverse
                    print("🎬 [ClippyLoadingView] Intro complete, playing reverse")
                    isPlayingIntro = false
                    isPlayingReverse = true
                    currentFrame = loopEndFrame
                } else {
                    currentFrame += 1
                }
            } else if isPlayingReverse {
                // Playing reverse (frames 300-133 backward)
                if currentFrame <= loopStartFrame {
                    // Reverse complete, switch to forward
                    print("🎬 [ClippyLoadingView] Reverse complete, playing forward")
                    isPlayingReverse = false
                    currentFrame = loopStartFrame
                } else {
                    currentFrame -= 1
                }
            } else {
                // Playing forward loop (frames 133-300 forward)
                if currentFrame >= loopEndFrame {
                    // Forward complete, switch to reverse
                    print("🎬 [ClippyLoadingView] Forward complete, playing reverse")
                    isPlayingReverse = true
                    currentFrame = loopEndFrame
                } else {
                    currentFrame += 1
                }
            }
        }
        
        @MainActor
        func setupVideoPlayback(isProcessing: Bool, resetID: UUID) async {
            // Not used anymore, but keeping for compatibility
        }
        
        @MainActor
        func updatePlaybackState(isProcessing: Bool, resetID: UUID) {
            if currentResetID != resetID {
                Task {
                    await startAnimation(resetID: resetID)
                }
            }
        }
    }
    
    private func createFallbackView() -> NSView {
        print("📎 [ClippyLoadingView] Creating fallback view with paperclip emoji")
        let fallbackView = NSView()
        fallbackView.wantsLayer = true
        fallbackView.layer?.backgroundColor = NSColor.clear.cgColor
        
        let textField = NSTextField(labelWithString: "📎")
        textField.font = NSFont.systemFont(ofSize: 64)
        textField.alignment = .center
        textField.backgroundColor = .clear
        textField.isBordered = false
        fallbackView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.centerXAnchor.constraint(equalTo: fallbackView.centerXAnchor),
            textField.centerYAnchor.constraint(equalTo: fallbackView.centerYAnchor)
        ])
        
        print("📎 [ClippyLoadingView] Fallback view created successfully")
        return fallbackView
    }
}

// MARK: - Thinking Cloud Animation

private struct ThinkingCloud: View {
    @State private var dotOpacity1: Double = 0.3
    @State private var dotOpacity2: Double = 0.3
    @State private var dotOpacity3: Double = 0.3
    @State private var cloudScale: CGFloat = 0.8
    
    var body: some View {
        ZStack {
            // Cloud shape
            CloudShape()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                .scaleEffect(cloudScale)
            
            // Thinking dots
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.gray.opacity(0.8))
                    .frame(width: 8, height: 8)
                    .opacity(dotOpacity1)
                
                Circle()
                    .fill(Color.gray.opacity(0.8))
                    .frame(width: 8, height: 8)
                    .opacity(dotOpacity2)
                
                Circle()
                    .fill(Color.gray.opacity(0.8))
                    .frame(width: 8, height: 8)
                    .opacity(dotOpacity3)
            }
            .offset(y: -4)
        }
        .onAppear {
            startAnimating()
        }
    }
    
    private func startAnimating() {
        // Cloud breathing animation
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            cloudScale = 1.0
        }
        
        // Animated thinking dots with cascading effect
        withAnimation(.easeInOut(duration: 0.6).repeatForever()) {
            dotOpacity1 = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.6).repeatForever()) {
                dotOpacity2 = 1.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeInOut(duration: 0.6).repeatForever()) {
                dotOpacity3 = 1.0
            }
        }
    }
}

private struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // Main cloud body (rounded rectangle base)
        let mainBody = CGRect(
            x: width * 0.15,
            y: height * 0.35,
            width: width * 0.7,
            height: height * 0.4
        )
        path.addRoundedRect(in: mainBody, cornerSize: CGSize(width: height * 0.2, height: height * 0.2))
        
        // Top left puff
        path.addEllipse(in: CGRect(
            x: width * 0.1,
            y: height * 0.25,
            width: width * 0.35,
            height: height * 0.35
        ))
        
        // Top middle puff
        path.addEllipse(in: CGRect(
            x: width * 0.3,
            y: height * 0.15,
            width: width * 0.4,
            height: height * 0.4
        ))
        
        // Top right puff
        path.addEllipse(in: CGRect(
            x: width * 0.5,
            y: height * 0.25,
            width: width * 0.35,
            height: height * 0.35
        ))
        
        // Small tail pointing to dog
        let tailPath = Path { p in
            p.move(to: CGPoint(x: width * 0.15, y: height * 0.7))
            p.addQuadCurve(
                to: CGPoint(x: width * 0.05, y: height * 0.9),
                control: CGPoint(x: width * 0.08, y: height * 0.75)
            )
            p.addQuadCurve(
                to: CGPoint(x: width * 0.25, y: height * 0.75),
                control: CGPoint(x: width * 0.12, y: height * 0.85)
            )
            p.closeSubpath()
        }
        path.addPath(tailPath)
        
        return path
    }
}

#Preview {
    VStack(spacing: 40) {
        ClippyLoadingView(isLoading: true, message: "Processing...")
        
        ClippyLoadingView(isLoading: false, message: "Ready!")
        
        // Preview thinking cloud separately
        ThinkingCloud()
            .frame(width: 64, height: 64)
            .padding()
    }
    .padding(40)
    .background(Color.black.opacity(0.8))
}
