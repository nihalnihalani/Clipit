import SwiftUI
import SwiftData

enum AIServiceType: String, CaseIterable {
    case openai = "OpenAI"
    case local = "Local AI"
    
    var description: String {
        switch self {
        case .openai:
            return "OpenAI GPT-5-nano (Cloud)"
        case .local:
            return "Local Qwen3-4b (On-device)"
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.timestamp, order: .reverse) private var items: [Item]
    @StateObject private var clipboardMonitor = ClipboardMonitor()
    @StateObject private var embeddingService = EmbeddingService()
    @StateObject private var hotkeyManager = HotkeyManager()
    @StateObject private var visionParser = VisionScreenParser()
    @StateObject private var textCaptureService = TextCaptureService()
    @State private var openAIService: OpenAIService = OpenAIService(apiKey: "")
    @State private var localAIService: LocalAIService = LocalAIService()
    @State private var apiKey: String = ""
    @State private var showAPIKeyInput: Bool = false
    @State private var selectedAIService: AIServiceType = .openai
    @State private var lastCapturedText: String = ""
    @State private var isProcessingAnswer: Bool = false
    @StateObject private var floatingDogController = FloatingDogWindowController()
    @State private var editingTagsFor: Item?
    @State private var newTagInput: String = ""

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                // Dog Behavior
                VStack(spacing: 12) {
                    Toggle("Show dog when active", isOn: $floatingDogController.followTextInput)
                        .help("When enabled, the dog will appear in the top-right corner when you're using text inputs. Press ESC to dismiss it.")
                        .onChange(of: floatingDogController.followTextInput) { _, newValue in
                            floatingDogController.setFollowTextInput(newValue)
                        }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                Divider()
                
                // AI Service Selection
                VStack(spacing: 12) {
                    Picker("AI Service", selection: $selectedAIService) {
                        ForEach(AIServiceType.allCases, id: \.self) { service in
                            Text(service.description).tag(service)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                // OpenAI API Key Settings (only show when OpenAI is selected)
                if selectedAIService == .openai {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("OpenAI Configuration")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button(showAPIKeyInput ? "Hide" : "Configure") {
                                showAPIKeyInput.toggle()
                            }
                            .buttonStyle(.bordered)
                        }
                    
                        if showAPIKeyInput {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    SecureField("Enter OpenAI API Key (sk-...)", text: $apiKey)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                    Button("Save") {
                                        saveAPIKey()
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .disabled(apiKey.isEmpty)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Get your API key from platform.openai.com")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Enables AI-powered answers based on your clipboard history")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                if !getStoredAPIKey().isEmpty {
                                    HStack(spacing: 6) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.caption)
                                        Text("API Key configured (\(maskAPIKey(getStoredAPIKey())))")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                            .padding(12)
                            .background(Color.purple.opacity(0.08))
                            .cornerRadius(8)
                        } else if !getStoredAPIKey().isEmpty {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                Text("API Key: \(maskAPIKey(getStoredAPIKey()))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .font(.caption)
                                Text("No API key configured")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                
                // Local AI Status (only show when Local AI is selected)
                if selectedAIService == .local {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "server.rack")
                                .foregroundColor(.blue)
                                .font(.subheadline)
                            Text("Local AI Configuration")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                Text("Endpoint: http://10.0.0.138:1234")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack(spacing: 6) {
                                Image(systemName: "brain.head.profile")
                                    .foregroundColor(.purple)
                                    .font(.caption)
                                Text("Model: qwen/qwen3-4b")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("Running locally - no API key required")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        .padding(12)
                        .background(Color.blue.opacity(0.08))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                
                Divider()
                
                // Keyboard Shortcut
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Text("⌥X")
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue)
                            .cornerRadius(6)
                        
                        Text("Ask a question and get an AI answer")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                // Permission Status
                if !clipboardMonitor.hasAccessibilityPermission {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                            Text("Accessibility permission required")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        
                        HStack(spacing: 12) {
                            Button("Grant Permission") {
                                clipboardMonitor.requestAccessibilityPermission()
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button("Open Settings") {
                                clipboardMonitor.openSystemPreferences()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                
                Divider()
                
                // Clipboard History
                List {
                    ForEach(items) { item in
                        HStack(spacing: 8) {
                            NavigationLink {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Clipboard Item Details")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    // Show image or text content
                                    if item.contentType == "image", let imagePath = item.imagePath, let nsImage = loadImage(from: imagePath) {
                                        VStack(alignment: .leading, spacing: 12) {
                                            Text("Image:")
                                                .font(.headline)
                                                .foregroundColor(.secondary)
                                            
                                            Text(item.content)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .padding(8)
                                                .background(Color.blue.opacity(0.1))
                                                .cornerRadius(6)
                                            
                                            Image(nsImage: nsImage)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(maxHeight: 400)
                                                .cornerRadius(8)
                                            
                                            Button(action: {
                                                copyImageToClipboard(imagePath: imagePath)
                                            }) {
                                                Label("Copy to Clipboard", systemImage: "doc.on.clipboard")
                                            }
                                            .buttonStyle(.borderedProminent)
                                        }
                                    } else {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Content:")
                                                .font(.headline)
                                                .foregroundColor(.secondary)
                                            Text(item.content)
                                                .padding()
                                                .background(Color.gray.opacity(0.1))
                                                .cornerRadius(8)
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("App:")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                        Text(item.appName ?? "Unknown App")
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Timestamp:")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                                    }
                                    
                                    // Tags section (always show, editable)
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text("Tags:")
                                                .font(.headline)
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Button(action: {
                                                editingTagsFor = (editingTagsFor?.id == item.id) ? nil : item
                                                newTagInput = ""
                                            }) {
                                                Image(systemName: editingTagsFor?.id == item.id ? "checkmark.circle.fill" : "pencil.circle")
                                                    .foregroundColor(editingTagsFor?.id == item.id ? .green : .blue)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                        
                                        if !item.tags.isEmpty {
                                            FlowLayout(spacing: 6) {
                                                ForEach(item.tags, id: \.self) { tag in
                                                    HStack(spacing: 4) {
                                                        Text(tag)
                                                            .font(.caption)
                                                        
                                                        if editingTagsFor?.id == item.id {
                                                            Button(action: {
                                                                removeTag(tag, from: item)
                                                            }) {
                                                                Image(systemName: "xmark.circle.fill")
                                                                    .font(.system(size: 10))
                                                                    .foregroundColor(.red.opacity(0.7))
                                                            }
                                                            .buttonStyle(.plain)
                                                        }
                                                    }
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Color.blue.opacity(0.2))
                                                    .foregroundColor(.blue)
                                                    .cornerRadius(4)
                                                }
                                            }
                                        } else {
                                            Text("No tags yet")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .italic()
                                        }
                                        
                                        if editingTagsFor?.id == item.id {
                                            HStack {
                                                TextField("Add tag...", text: $newTagInput)
                                                    .textFieldStyle(.roundedBorder)
                                                    .onSubmit {
                                                        addTag(to: item)
                                                    }
                                                
                                                Button("Add") {
                                                    addTag(to: item)
                                                }
                                                .buttonStyle(.borderedProminent)
                                                .disabled(newTagInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                            }
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    // Show image indicator with AI summary or text content
                                    if item.contentType == "image" {
                                        HStack(spacing: 6) {
                                            Image(systemName: "photo")
                                                .foregroundColor(.blue)
                                            Text(item.content)
                                                .lineLimit(2)
                                                .font(.body)
                                        }
                                    } else {
                                        Text(item.content)
                                            .lineLimit(2)
                                            .font(.body)
                                    }
                                    
                                    // Show tags inline if available
                                    if !item.tags.isEmpty {
                                        HStack(spacing: 4) {
                                            ForEach(item.tags.prefix(3), id: \.self) { tag in
                                                Text(tag)
                                                    .font(.system(size: 9))
                                                    .padding(.horizontal, 4)
                                                    .padding(.vertical, 2)
                                                    .background(Color.blue.opacity(0.2))
                                                    .foregroundColor(.blue)
                                                    .cornerRadius(3)
                                            }
                                            if item.tags.count > 3 {
                                                Text("+\(item.tags.count - 3)")
                                                    .font(.system(size: 9))
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                    
                                    HStack {
                                        Text(item.appName ?? "Unknown App")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                        
                                        Text(item.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .contextMenu {
                                if item.contentType == "image", let imagePath = item.imagePath {
                                    Button(action: {
                                        copyImageToClipboard(imagePath: imagePath)
                                    }) {
                                        Label("Copy Image", systemImage: "doc.on.clipboard")
                                    }
                                } else {
                                    Button(action: {
                                        let pasteboard = NSPasteboard.general
                                        pasteboard.clearContents()
                                        pasteboard.setString(item.content, forType: .string)
                                    }) {
                                        Label("Copy Text", systemImage: "doc.on.clipboard")
                                    }
                                }
                                
                                Divider()
                                
                                Button(role: .destructive, action: {
                                    deleteItem(item)
                                }) {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            
                            // Quick copy button for images
                            if item.contentType == "image", let imagePath = item.imagePath {
                                Button(action: {
                                    copyImageToClipboard(imagePath: imagePath)
                                }) {
                                    Image(systemName: "doc.on.clipboard")
                                        .foregroundColor(.blue)
                                        .frame(width: 20, height: 20)
                                }
                                .buttonStyle(.plain)
                                .help("Copy image to clipboard")
                            }
                            
                            // Delete button
                            Button(action: {
                                deleteItem(item)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .frame(width: 20, height: 20)
                            }
                            .buttonStyle(.plain)
                            .help("Delete this clipboard item")
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationSplitViewColumnWidth(min: 300, ideal: 400)
            .toolbar {
                ToolbarItem {
                    Button(action: toggleMonitoring) {
                        Label(clipboardMonitor.isMonitoring ? "Stop Monitoring" : "Start Monitoring", 
                              systemImage: clipboardMonitor.isMonitoring ? "stop.circle" : "play.circle")
                    }
                }
                
                ToolbarItem {
                    Button(action: clearHistory) {
                        Label("Clear History", systemImage: "trash")
                    }
                }
            }
        } detail: {
            Text("Select a clipboard item to view details")
        }
        .onChange(of: selectedAIService) { _, newValue in
            UserDefaults.standard.set(newValue.rawValue, forKey: "SelectedAIService")
        }
        .onAppear {
            // Load stored AI service selection
            if let savedServiceString = UserDefaults.standard.string(forKey: "SelectedAIService"),
               let savedService = AIServiceType(rawValue: savedServiceString) {
                selectedAIService = savedService
            }
            
            // Load stored API key
            let storedKey = getStoredAPIKey()
            if !storedKey.isEmpty {
                openAIService = OpenAIService(apiKey: storedKey)
            }
            
            Task {
                await embeddingService.initialize()
                clipboardMonitor.startMonitoring(
                    modelContext: modelContext,
                    embeddingService: embeddingService,
                    openAIService: openAIService
                )
                
                // Start hotkey listener
                hotkeyManager.startListening(
                    onTrigger: {
                        handleHotkeyTrigger()
                    },
                    onVisionTrigger: {
                        handleVisionHotkeyTrigger()
                    },
                    onTextCaptureTrigger: {
                        handleTextCaptureTrigger()
                    }
                )
            }
        }
        .onDisappear {
            clipboardMonitor.stopMonitoring()
            hotkeyManager.stopListening()
        }
    }

    private func toggleMonitoring() {
        if clipboardMonitor.isMonitoring {
            clipboardMonitor.stopMonitoring()
        } else {
            clipboardMonitor.startMonitoring(
                modelContext: modelContext,
                embeddingService: embeddingService,
                openAIService: openAIService
            )
        }
    }
    
    private func clearHistory() {
        withAnimation {
            for item in items {
                modelContext.delete(item)
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let item = items[index]
                if let vid = item.vectorId {
                    embeddingService.deleteDocument(vectorId: vid)
                }
                modelContext.delete(item)
            }
        }
    }
    
    private func deleteItem(_ item: Item) {
        withAnimation {
            if let vid = item.vectorId {
                embeddingService.deleteDocument(vectorId: vid)
            }
            modelContext.delete(item)
        }
    }
    
    private func addTag(to item: Item) {
        let trimmedTag = newTagInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTag.isEmpty else { return }
        
        // Avoid duplicates
        guard !item.tags.contains(trimmedTag) else {
            newTagInput = ""
            return
        }
        
        item.tags.append(trimmedTag)
        try? modelContext.save()
        newTagInput = ""
        
        print("🏷️  [ContentView] Manually added tag '\(trimmedTag)' to item")
    }
    
    private func removeTag(_ tag: String, from item: Item) {
        item.tags.removeAll { $0 == tag }
        try? modelContext.save()
        
        print("🗑️ [ContentView] Manually removed tag '\(tag)' from item")
    }
    
    private func handleHotkeyTrigger() {
        print("\n🔥 [ContentView] Hotkey triggered (Option+X)")
        print("   Current app: \(clipboardMonitor.currentAppName)")
        print("   Available items in DB: \(items.count)")
        
        // This is now handled by the text capture service
        // The hotkey manager will trigger the text capture flow
    }
    
    

    private var hasAccessibilityInfo: Bool {
        clipboardMonitor.hasAccessibilityPermission && !clipboardMonitor.accessibilityContext.isEmpty
    }
    
    // MARK: - Vision Parser Functions
    
    private func parseCurrentScreen() {
        visionParser.parseCurrentScreen { result in
            switch result {
            case .success(let parsedContent):
                print("✅ Vision parsing successful!")
                print("   📝 Extracted \(parsedContent.fullText.count) characters")
                print("   🎯 Confidence: \(String(format: "%.1f", parsedContent.confidence * 100))%")
                print("   ⏱️ Processing time: \(String(format: "%.2f", parsedContent.processingTime))s")
                
                // Optionally add to clipboard history (with deduplication)
                if !parsedContent.fullText.isEmpty {
                    // Check if exact same content already exists
                    let contentToCheck = parsedContent.fullText
                    let fetchDescriptor = FetchDescriptor<Item>(
                        predicate: #Predicate<Item> { item in
                            item.content == contentToCheck
                        },
                        sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
                    )
                    
                    do {
                        let existingItems = try modelContext.fetch(fetchDescriptor)
                        if existingItems.isEmpty {
                            // Only save if it doesn't already exist
                            let item = Item(
                                timestamp: Date(),
                                content: parsedContent.fullText,
                                appName: clipboardMonitor.currentAppName,
                                contentType: "vision-parsed"
                            )
                            modelContext.insert(item)
                            try? modelContext.save()
                            print("   💾 Saved vision-parsed content to clipboard history")
                        } else {
                            print("   ⚠️ Vision-parsed content already exists, skipping duplicate")
                        }
                    } catch {
                        print("   ⚠️ Failed to check for duplicates: \(error)")
                    }
                }
                
            case .failure(let error):
                print("❌ Vision parsing failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func handleVisionHotkeyTrigger() {
        print("\n👁️ [ContentView] Vision hotkey triggered (Option+V)")
        print("   Current app: \(clipboardMonitor.currentAppName)")
        print("   Window title: \(clipboardMonitor.currentWindowTitle)")
        
        // Parse current screen
        parseCurrentScreen()
    }
    
    private func handleTextCaptureTrigger() {
        print("\n⌨️ [ContentView] Text capture hotkey triggered (Option+X)")
        
        if textCaptureService.isCapturing {
            // Already capturing, this will stop it and trigger the callback
            print("   Stopping text capture...")
            textCaptureService.stopCapturing()
            // Don't hide - let processCapturedText handle showing the thinking cloud
        } else {
            // Start capturing
            print("   Starting text capture...")
            floatingDogController.show(message: "PastePup is listening...", isLoading: false)
            
            textCaptureService.startCapturing { capturedText in
                print("   ✅ Text captured: '\(capturedText)'")
                self.lastCapturedText = capturedText
                
                // Process the captured text with clipboard context
                self.processCapturedText(capturedText)
            }
        }
    }
    
    private func processCapturedText(_ capturedText: String) {
        print("\n🎯 [ContentView] Processing captured text...")
        print("   Captured text: '\(capturedText)'")
        print("   Current app: \(clipboardMonitor.currentAppName)")
        print("   Available items in DB: \(items.count)")
        
        isProcessingAnswer = true
        floatingDogController.updateMessage("PastePup is thinking...", isLoading: true)
        
        Task {
            // Get recent clipboard items for context (with tags)
            let recentItems = Array(items.prefix(10))
            let clipboardContext = recentItems.map { (content: $0.content, tags: $0.tags) }
            
            print("   🎯 Clipboard context: \(clipboardContext.count) items")
            print("   Items with tags: \(clipboardContext.filter { !$0.tags.isEmpty }.count)")
            
            // Generate answer using selected AI service (with image detection for OpenAI)
            let answer: String?
            let imageIndex: Int?
            
            switch selectedAIService {
            case .openai:
                (answer, imageIndex) = await openAIService.generateAnswerWithImageDetection(
                    question: capturedText,
                    clipboardContext: clipboardContext,
                    appName: clipboardMonitor.currentAppName
                )
            case .local:
                answer = await localAIService.generateAnswer(
                    question: capturedText,
                    clipboardContext: clipboardContext,
                    appName: clipboardMonitor.currentAppName
                )
                imageIndex = nil
            }
            
            // Check if AI wants to paste an image
            if let imageIndex = imageIndex, imageIndex > 0, imageIndex <= recentItems.count {
                let item = recentItems[imageIndex - 1]
                
                if item.contentType == "image", let imagePath = item.imagePath {
                    print("   🖼️ Pasting image from item \(imageIndex)")
                    
                    // Copy image to clipboard
                    copyImageToClipboard(imagePath: imagePath)
                    
                    // Delete the original item from history to avoid duplicates
                    await MainActor.run {
                        print("   🗑️ Deleting original image item from history")
                        if let vid = item.vectorId {
                            embeddingService.deleteDocument(vectorId: vid)
                        }
                        modelContext.delete(item)
                        try? modelContext.save()
                    }
                    
                    // Simulate paste (Cmd+V)
                    await MainActor.run {
                        // Delete the captured text first
                        textCaptureService.replaceCapturedTextWithAnswer("")
                        
                        // Small delay to ensure text is cleared
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            // Simulate Cmd+V
                            let source = CGEventSource(stateID: .hidSystemState)
                            let vKeyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
                            let vKeyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
                            vKeyDown?.flags = .maskCommand
                            vKeyUp?.flags = .maskCommand
                            vKeyDown?.post(tap: .cghidEventTap)
                            vKeyUp?.post(tap: .cghidEventTap)
                            
                            self.floatingDogController.updateMessage("Image pasted! 🖼️", isLoading: false)
                        }
                    }
                } else {
                    print("   ⚠️ Item \(imageIndex) is not an image")
                    await MainActor.run {
                        floatingDogController.updateMessage("That's not an image 🤔", isLoading: false)
                    }
                }
            } else if let answer = answer {
                // Check if answer is empty or just whitespace
                let trimmedAnswer = answer.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if !trimmedAnswer.isEmpty {
                    print("   ✅ Generated answer: \(answer.prefix(100))...")
                    
                    // Replace the captured text with the answer
                    textCaptureService.replaceCapturedTextWithAnswer(answer)
                    
                    // Show success message briefly
                    await MainActor.run {
                        floatingDogController.updateMessage("Answer ready! 🎉", isLoading: false)
                    }
                } else {
                    print("   ℹ️ Question not relevant to clipboard history - no replacement")
                    
                    // Don't replace text, just show a message
                    await MainActor.run {
                        floatingDogController.updateMessage("Question not relevant to clipboard 📋", isLoading: false)
                    }
                }
            } else {
                print("   ❌ Failed to generate answer")
                // Fallback: show error message
                textCaptureService.replaceCapturedTextWithAnswer("Sorry, I couldn't generate an answer. Please check your API key and try again.")
                
                // Show error message briefly
                await MainActor.run {
                    floatingDogController.updateMessage("Oops! Something went wrong 😅", isLoading: false)
                }
            }
            
            // Stop loading animation
            await MainActor.run {
                isProcessingAnswer = false
                // Dog will auto-hide after showing result (handled by FloatingDogWindowController)
            }
        }
    }
    
    private func getLoadingMessage() -> String {
        if isProcessingAnswer {
            return "PastePup is thinking..."
        } else if textCaptureService.isCapturing {
            return "PastePup is listening..."
        } else {
            return "PastePup is ready to fetch!"
        }
    }
    
    // MARK: - API Key Management
    
    private func saveAPIKey() {
        UserDefaults.standard.set(apiKey, forKey: "OpenAI_API_Key")
        openAIService = OpenAIService(apiKey: apiKey)
        
        // Restart monitoring with new service
        clipboardMonitor.stopMonitoring()
        clipboardMonitor.startMonitoring(
            modelContext: modelContext,
            embeddingService: embeddingService,
            openAIService: openAIService
        )
        
        print("✅ API Key saved and service restarted")
        showAPIKeyInput = false
    }
    
    private func getStoredAPIKey() -> String {
        // Try environment variable first, then UserDefaults
        if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !envKey.isEmpty {
            return envKey
        }
        return UserDefaults.standard.string(forKey: "OpenAI_API_Key") ?? ""
    }
    
    private func maskAPIKey(_ key: String) -> String {
        guard key.count > 8 else { return "****" }
        let prefix = key.prefix(7)
        let suffix = key.suffix(4)
        return "\(prefix)...\(suffix)"
    }
    
    private func getImagesDirectory() -> URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return appSupport.appendingPathComponent("PastePup/Images")
    }
    
    private func loadImage(from path: String) -> NSImage? {
        let imageURL = getImagesDirectory().appendingPathComponent(path)
        return NSImage(contentsOf: imageURL)
    }
    
    private func copyImageToClipboard(imagePath: String) {
        let imageURL = getImagesDirectory().appendingPathComponent(imagePath)
        
        guard let nsImage = NSImage(contentsOf: imageURL) else {
            print("❌ Failed to load image from disk")
            return
        }
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        // Write image using writeObjects for proper clipboard handling
        pasteboard.writeObjects([nsImage])
        
        print("✅ Image copied to clipboard")
        print("   Pasteboard types: \(pasteboard.types ?? [])")
    }
}

// MARK: - FlowLayout Helper for Tags Display

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize
        var positions: [CGPoint]
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var positions: [CGPoint] = []
            var size: CGSize = .zero
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let subviewSize = subview.sizeThatFits(.unspecified)
                
                if currentX + subviewSize.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += subviewSize.width + spacing
                lineHeight = max(lineHeight, subviewSize.height)
                size.width = max(size.width, currentX - spacing)
                size.height = currentY + lineHeight
            }
            
            self.size = size
            self.positions = positions
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
