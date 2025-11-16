# Clippy Assets Download Instructions

This document provides links and instructions for downloading Clippy assets to replace the dog-themed assets in PastePup.

## Required Assets

### 1. Clippy Animated GIF (Primary Animation)
**File to replace:** `CuteDog.gif`

**Option A - LottieFiles (Recommended):**
- Visit: https://lottiefiles.com/free-animation/clippy-u9jOr2AeCn
- Download as GIF or Lottie JSON
- If downloading as Lottie, you'll need to convert to GIF using tools like:
  - https://lottiefiles.com/tools/lottie-to-gif
  - Or use a local converter

**Option B - Create Custom Clippy GIF:**
- Search GitHub for "clippy animation" repositories
- Example: https://github.com/smore-lore/clippy (JavaScript implementation)
- You can capture screen recordings and convert to GIF

**Option C - Paperclip Animation:**
- Use a simple animated paperclip if Clippy-specific animations aren't available
- Create a bouncing/rotating paperclip animation

**Download Location:** Save as `Clippy.gif` in the project root

### 2. Clippy Static PNG (Sprite/Icon)
**Files to replace:** `Corgi.png`, `puppy.png`

**Option A - Icons8 Paperclip Emoji:**
- Direct link: https://img.icons8.com/?id=CYKLk4DosdHW&format=png&size=512
- Download this 512x512 paperclip emoji

**Option B - SVGmix:**
- Visit: https://svgmix.com/item/Xo3N0X/microsoft-clippy
- Download as PNG (convert SVG if needed)

**Option C - SeekLogo:**
- Visit: https://seeklogo.com/vector-logo/92270/microsoft-clippy
- Download PNG or EPS format
- Convert EPS to PNG if needed (use CloudConvert or similar)

**Download Locations:**
- Save as `Clippy.png` in `PastePup/Assets.xcassets/ClippySprite.imageset/`
- Save another copy as `clippy-illustration.png` in `PastePup/Assets.xcassets/ClippyIllustration.imageset/`

### 3. Clippy Video (Optional)
**File to replace:** `CuteDog.mov`

You can either:
1. Create a short video animation of Clippy
2. Use a GIF-to-video converter on the Clippy GIF
3. Skip this file if only using GIF animation

**Download Location:** Save as `Clippy.mov` in the project root

## Installation Steps

1. Download the assets using the links above
2. Place files in the following locations:
   ```
   /PastePup/
   ├── Clippy.gif          (replaces CuteDog.gif)
   ├── Clippy.mov          (replaces CuteDog.mov - optional)
   └── Assets.xcassets/
       ├── ClippySprite.imageset/
       │   ├── Clippy.png
       │   └── Contents.json (will be auto-updated)
       └── ClippyIllustration.imageset/
           ├── clippy-illustration.png
           └── Contents.json (will be auto-updated)
   ```

3. The code has already been updated to reference these new filenames
4. Build and run the project

## Fallback Options

If you can't find suitable Clippy assets, the code includes fallback options:
- 📎 Paperclip emoji will be displayed
- Simple text-based representation

## License Considerations

**Important:** Clippy is a trademarked character by Microsoft. Usage considerations:
- Personal/educational projects: Generally acceptable
- Commercial projects: May require licensing or using a similar (but legally distinct) paperclip character
- Open source: Consider using a Creative Commons or public domain paperclip animation instead

For commercial use, consider:
1. Creating your own paperclip character design
2. Using generic paperclip animations from free asset libraries
3. Consulting with legal counsel regarding Microsoft's IP

## Asset Specifications

- **GIF Animation:** Should be around 128x128 to 256x256 pixels, transparent background
- **PNG Images:** 512x512 pixels or higher, transparent background (PNG-24)
- **Frame Rate:** 30 FPS recommended for smooth animation
- **File Size:** Try to keep GIF under 5MB for performance

## Testing

After adding the assets:
1. Clean build folder in Xcode (Shift + Cmd + K)
2. Rebuild project (Cmd + B)
3. Run application (Cmd + R)
4. Test the Clippy animation appears correctly

## Troubleshooting

If assets don't appear:
1. Check file names match exactly (case-sensitive)
2. Verify files are added to Xcode project (not just filesystem)
3. Check asset catalog in Xcode for proper configuration
4. Clean derived data and rebuild

For help, check the main README or TROUBLESHOOTING.md files.

