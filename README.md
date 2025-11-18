# ClipIt - Smart Clipboard Manager for Windows

ClipIt is an AI-powered clipboard manager for Windows that helps you organize, search, and intelligently retrieve your clipboard history using local AI models (Llama-3.2-1B).

## 🎬 Demo Videos

### ClipIt: AI Memory For Your PC

https://github.com/nihalnihalani/Clipit/raw/main/clipit/ClipIt__AI_Memory_For_Your_PC.mp4

<video src="https://github.com/nihalnihalani/Clipit/raw/main/clipit/ClipIt__AI_Memory_For_Your_PC.mp4" controls width="100%"></video>

A quick demonstration of ClipIt's core features and AI-powered clipboard search.

### ClipIt: AI-Powered Memory

https://github.com/nihalnihalani/Clipit/raw/main/clipit/ClipIt__AI-Powered_Memory.mp4

<video src="https://github.com/nihalnihalani/Clipit/raw/main/clipit/ClipIt__AI-Powered_Memory.mp4" controls width="100%"></video>

In-depth look at how ClipIt uses AI to understand and retrieve your clipboard history.

## ✨ Features

<table>
<tr>
<td>

### 📋 Clipboard Monitoring
Automatically captures all text and images you copy

</td>
<td>

### 🤖 AI-Powered Search
Ask questions about your clipboard history (Alt+X)

</td>
</tr>
<tr>
<td>

### 🏷️ Smart Tagging
Automatically organizes items with semantic tags

</td>
<td>

### 👁️ OCR Support
Extract text from screen with Alt+V

</td>
</tr>
<tr>
<td>

### 🐕 Floating Assistant
Visual feedback with cute dog animation

</td>
<td>

### ⌨️ Global Hotkeys
Quick access from any application

</td>
</tr>
<tr>
<td colspan="2">

### 💾 Persistent Storage
SQLite database keeps your history safe and searchable

</td>
</tr>
</table>

## 📥 Installation

### Prerequisites

- ![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D6?style=flat-square&logo=windows&logoColor=white) Windows 10 or Windows 11
- ![Python](https://img.shields.io/badge/Python-3.8+-3776AB?style=flat-square&logo=python&logoColor=white) Python 3.8 or higher
- ![Tesseract](https://img.shields.io/badge/Tesseract-OCR-blue?style=flat-square) Tesseract OCR (for screen text extraction)

### Install Tesseract OCR

1. Download Tesseract from: https://github.com/UB-Mannheim/tesseract/wiki
2. Install to default location or add to PATH

### Install ClipIt

```bash
# Clone the repository
git clone https://github.com/nihalnihalani/Clipit.git
cd Clipit

# Install dependencies
pip install -r requirements.txt

# Run the application
python -m clipit.main
```

## 🎮 Usage

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| **Alt+X** | Ask a question about your clipboard history |
| | • Press once to start typing your question |
| | • Press again to get an AI-generated answer |
| **Alt+V** | Extract text from current screen using OCR |
| **Alt+S** | Show clipboard suggestions |
| **ESC** | Dismiss the floating dog |

### Text Capture Flow

1. Press **Alt+X** - Floating dog appears with "Clipit is listening..."
2. Type your question (e.g., "what was that tracking number?")
3. Press **Alt+X** again to stop and process
4. Clipit searches your clipboard history and generates an answer
5. The answer replaces your typed question automatically

### Example Questions

```
💡 "what was that email address?"
💡 "tracking number"
💡 "the code snippet from earlier"
💡 "paste image 2" (pastes the 2nd most recent image)
```

## 🏗️ Architecture

For detailed architecture diagrams and technical documentation, see **[ARCHITECTURE.md](ARCHITECTURE.md)**.

### Tech Stack

| Component | Technology |
|-----------|-----------|
| **UI** | ![PyQt5](https://img.shields.io/badge/PyQt5-41CD52?style=flat-square&logo=qt&logoColor=white) PyQt5 |
| **AI Model** | ![Llama](https://img.shields.io/badge/Llama--3.2--1B-0467DF?style=flat-square&logo=meta&logoColor=white) Llama-3.2-1B via Hugging Face |
| **Database** | ![SQLite](https://img.shields.io/badge/SQLite-003B57?style=flat-square&logo=sqlite&logoColor=white) SQLite with SQLAlchemy ORM |
| **Clipboard** | ![Windows API](https://img.shields.io/badge/Windows_API-0078D6?style=flat-square&logo=windows&logoColor=white) pywin32 |
| **Hotkeys** | ![Keyboard](https://img.shields.io/badge/pynput-keyboard-green?style=flat-square) pynput |
| **OCR** | ![Tesseract](https://img.shields.io/badge/Tesseract-OCR-blue?style=flat-square) pytesseract |

## ⚙️ Configuration

The application stores data in:
- **Database**: `%APPDATA%/Clipit/clipit.db`
- **Images**: `%APPDATA%/Clipit/images/`

## 💻 Development

### Project Structure

```
Clipit/
├── clipit/                  # Main application package
│   ├── main.py              # Application entry point
│   ├── ui/                  # User interface components
│   ├── services/            # Core services (clipboard, AI, OCR)
│   ├── models/              # Database models
│   └── utils/               # Utilities
├── requirements.txt         # Python dependencies
├── test_clipit.py          # Test suite
├── run.bat                 # Windows launcher script
├── ARCHITECTURE.md         # Architecture diagrams
└── README.md               # This file
```

## ⚠️ Known Limitations

- Llama-3.2-1B is a relatively small model; complex queries may not work perfectly
- Image analysis is limited (uses separate vision model if available)
- OCR quality depends on screen content and Tesseract configuration
- Antivirus software may flag keyboard hooks as suspicious

## 🧪 Testing

See **[TESTING.md](TESTING.md)** for comprehensive testing procedures.

## 🔧 Troubleshooting

See **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** for common issues and solutions.

## 📄 License

This project is ClipIt, a Windows-native clipboard manager.

## 🙏 Acknowledgments

- Original PastePup concept (macOS/Swift)
- Meta's Llama-3.2-1B language model
- Tesseract OCR project
- PyQt5 framework

## 📜 Project History

This repository originally contained PastePup (a macOS Swift app), but has been fully converted to ClipIt (Windows Python app). All macOS/Swift code has been removed to focus exclusively on the Windows implementation.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## 💬 Support

For support and questions:
- ![GitHub Issues](https://img.shields.io/badge/GitHub-Issues-181717?style=flat-square&logo=github) Open an issue on GitHub
- ![Documentation](https://img.shields.io/badge/Docs-ARCHITECTURE.md-blue?style=flat-square) Check the documentation in ARCHITECTURE.md
- ![Troubleshooting](https://img.shields.io/badge/Help-TROUBLESHOOTING.md-orange?style=flat-square) Review TROUBLESHOOTING.md for common problems

---

<div align="center">

**Made with ❤️ for productivity**

![Python](https://img.shields.io/badge/Python-3.8+-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![AI Powered](https://img.shields.io/badge/AI-Powered-FF6B6B?style=for-the-badge)

</div>
