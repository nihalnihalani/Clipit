# Clipit - Smart Clipboard Manager for Windows

Clipit is an AI-powered clipboard manager for Windows that helps you organize, search, and intelligently retrieve your clipboard history using the LFM2-350M language model.

## Features

- 📋 **Automatic Clipboard Monitoring**: Captures all text and images you copy
- 🤖 **AI-Powered Answers**: Ask questions about your clipboard history (Alt+X)
- 🏷️ **Smart Tagging**: Automatically tags clipboard items for better organization
- 🔍 **OCR Support**: Extract text from screen with Alt+V
- 🐕 **Floating Assistant**: Cute dog animation shows processing status
- ⌨️ **Global Hotkeys**: Quick access from any application
- 💾 **Persistent Storage**: SQLite database keeps your history safe

## Installation

### Prerequisites

- Windows 10 or Windows 11
- Python 3.8 or higher
- Tesseract OCR (for screen text extraction)

### Install Tesseract OCR

1. Download Tesseract from: https://github.com/UB-Mannheim/tesseract/wiki
2. Install to default location or add to PATH

### Install Clipit

```bash
# Clone the repository
cd clipit

# Install dependencies
pip install -r requirements.txt

# Run the application
python -m clipit.main
```

## Usage

### Keyboard Shortcuts

- **Alt+X**: Ask a question about your clipboard history
  - Press once to start typing your question
  - Press again to get an AI-generated answer
- **Alt+V**: Extract text from current screen using OCR
- **Alt+S**: Show clipboard suggestions (legacy)
- **ESC**: Dismiss the floating dog

### Text Capture Flow

1. Press **Alt+X** - Floating dog appears with "Clipit is listening..."
2. Type your question (e.g., "what was that tracking number?")
3. Press **Alt+X** again to stop and process
4. Clipit searches your clipboard history and generates an answer
5. The answer replaces your typed question automatically

### Example Questions

- "what was that email address?"
- "tracking number"
- "the code snippet from earlier"
- "paste image 2" (pastes the 2nd most recent image)

## Architecture

- **UI**: PyQt5 for native Windows look and feel
- **AI Model**: LFM2-350M via Hugging Face Transformers
- **Database**: SQLite with SQLAlchemy ORM
- **Clipboard**: Windows API via pywin32
- **Hotkeys**: Global keyboard hooks via pynput
- **OCR**: Tesseract via pytesseract

## Configuration

The application stores data in:
- Database: `%APPDATA%/Clipit/clipit.db`
- Images: `%APPDATA%/Clipit/images/`

## Development

### Project Structure

```
clipit/
├── clipit/
│   ├── main.py              # Application entry point
│   ├── ui/                  # User interface components
│   ├── services/            # Core services (clipboard, AI, OCR)
│   ├── models/              # Database models
│   └── utils/               # Utilities
└── assets/                  # Images and resources
```

## Known Limitations

- LFM2-350M is a relatively small model; complex queries may not work perfectly
- Image analysis is limited (uses separate vision model if available)
- OCR quality depends on screen content and Tesseract configuration
- Antivirus software may flag keyboard hooks as suspicious

## License

This project is a Windows port of PastePup, migrated from Swift/macOS to Python/Windows.

## Acknowledgments

- Original PastePup application for macOS
- Meta's LFM2-350M language model
- Tesseract OCR project

