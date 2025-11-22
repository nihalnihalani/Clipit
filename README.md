<div align="center">

# <img src="https://img.icons8.com/?size=48&id=79020&format=png" alt="Clipboard" width="40"/> ClipIt

### AI-Powered Clipboard Manager for Windows

<p align="center">
  <img src="https://img.shields.io/badge/Windows-10%2F11-0078D6?style=for-the-badge&logo=windows&logoColor=white" alt="Windows">
  <img src="https://img.shields.io/badge/Python-3.8+-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python">
  <img src="https://img.shields.io/badge/AI-Powered-FF6B6B?style=for-the-badge&logo=openai&logoColor=white" alt="AI Powered">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License">
</p>

<p align="center">
  <strong>Never lose your clipboard history again. Search it with AI.</strong>
</p>

<p align="center">
  <a href="#-features">Features</a> •
  <a href="#-demo">Demo</a> •
  <a href="#-installation">Installation</a> •
  <a href="#-usage">Usage</a> •
  <a href="#-architecture">Architecture</a> •
  <a href="#-support">Support</a>
</p>

---

</div>

## <img src="https://img.icons8.com/?size=32&id=59862&format=png" alt="Video"/> Demo

### <img src="https://img.icons8.com/color/24/000000/youtube-play.png" alt="YouTube"/> Watch on YouTube

[![ClipIt Demo Video](https://img.youtube.com/vi/prX3y_jcd90/maxresdefault.jpg)](https://www.youtube.com/watch?v=prX3y_jcd90)

**[▶️ Watch Full Demo on YouTube](https://www.youtube.com/watch?v=prX3y_jcd90)**

See ClipIt in action with AI-powered clipboard management and smart text retrieval.

---

## <img src="https://img.icons8.com/?size=32&id=60003&format=png" alt="Features"/> Features

<table>
<tr>
<td width="50%">

### <img src="https://img.icons8.com/?size=24&id=79020&format=png" alt="Clipboard"/> **Clipboard Monitoring**
Automatically captures all text and images you copy, creating a searchable history that never forgets.

</td>
<td width="50%">

### <img src="https://img.icons8.com/?size=24&id=37410&format=png" alt="AI"/> **AI-Powered Search**
Ask natural language questions about your clipboard history using local AI (Llama-3.2-1B). Press `Alt+X` to start!

</td>
</tr>
<tr>
<td width="50%">

### <img src="https://img.icons8.com/?size=24&id=59868&format=png" alt="Tag"/> **Smart Tagging**
Automatically organizes clipboard items with semantic tags for easy categorization and retrieval.

</td>
<td width="50%">

### <img src="https://img.icons8.com/?size=24&id=cEcenq1dEbND&format=png" alt="OCR"/> **OCR Support**
Extract text from anywhere on your screen with `Alt+V` using powerful Tesseract OCR engine.

</td>
</tr>
<tr>
<td width="50%">

### <img src="https://img.icons8.com/?size=24&id=PGpXkTUdCHk8&format=png" alt="Dog"/> **Floating Assistant**
Adorable dog animation provides visual feedback and makes clipboard management delightful.

</td>
<td width="50%">

### <img src="https://img.icons8.com/?size=24&id=60677&format=png" alt="Keyboard"/> **Global Hotkeys**
Quick access from any application with customizable keyboard shortcuts.

</td>
</tr>
<tr>
<td colspan="2">

### <img src="https://img.icons8.com/?size=24&id=11360&format=png" alt="Database"/> **Persistent Storage**
SQLite database keeps your clipboard history safe, searchable, and available even after restarts.

</td>
</tr>
</table>

---

## <img src="https://img.icons8.com/?size=32&id=59881&format=png" alt="Installation"/> Installation

### Prerequisites

<table>
<tr>
<td>

**<img src="https://img.icons8.com/?size=20&id=108792&format=png" alt="OS"/> Operating System**
```
Windows 10 or Windows 11
```

</td>
<td>

**<img src="https://img.icons8.com/?size=20&id=13441&format=png" alt="Python"/> Python**
```
Python 3.8 or higher
```

</td>
<td>

**<img src="https://img.icons8.com/?size=20&id=60006&format=png" alt="OCR"/> Tesseract OCR**
```
For screen text extraction
```

</td>
</tr>
</table>

### Step 1: Install Tesseract OCR

1. Download Tesseract from: [UB-Mannheim/tesseract](https://github.com/UB-Mannheim/tesseract/wiki)
2. Install to default location or add to PATH

### Step 2: Install ClipIt

```bash
# Clone the repository
git clone https://github.com/nihalnihalani/Clipit.git
cd Clipit

# Install dependencies
pip install -r requirements.txt

# Run the application
python -m clipit.main
```

### Quick Start (Windows)

Double-click `run.bat` to launch ClipIt with a single click!

---

## <img src="https://img.icons8.com/?size=32&id=24880&format=png" alt="Usage"/> Usage

### <img src="https://img.icons8.com/?size=24&id=60677&format=png" alt="Shortcuts"/> Keyboard Shortcuts

<div align="center">

| Shortcut | Action | Description |
|:--------:|:-------|:------------|
| `Alt+X` | **<img src="https://img.icons8.com/?size=16&id=37410&format=png" alt="AI"/> Ask AI** | Press once to start typing your question, press again to get an AI-generated answer |
| `Alt+V` | **<img src="https://img.icons8.com/?size=16&id=cEcenq1dEbND&format=png" alt="OCR"/> OCR Capture** | Extract text from current screen using OCR technology |
| `Alt+S` | **<img src="https://img.icons8.com/?size=16&id=82774&format=png" alt="Suggestions"/> Show Suggestions** | Display clipboard suggestions based on context |
| `ESC` | **<img src="https://img.icons8.com/?size=16&id=3062&format=png" alt="Dismiss"/> Dismiss** | Hide the floating dog assistant |

</div>

### <img src="https://img.icons8.com/?size=24&id=83219&format=png" alt="Workflow"/> AI Search Workflow

**Example Flow:**
1. <img src="https://img.icons8.com/?size=16&id=60677&format=png" alt="Press"/> **Press `Alt+X`** - Floating dog appears with "Clipit is listening..."
2. <img src="https://img.icons8.com/?size=16&id=59879&format=png" alt="Type"/> **Type your question** - e.g., "what was that tracking number?"
3. <img src="https://img.icons8.com/?size=16&id=60677&format=png" alt="Press"/> **Press `Alt+X` again** - To stop and process
4. <img src="https://img.icons8.com/?size=16&id=37410&format=png" alt="AI"/> **AI searches** - ClipIt searches your clipboard history
5. <img src="https://img.icons8.com/?size=16&id=59872&format=png" alt="Done"/> **Answer appears** - The answer replaces your question automatically

### <img src="https://img.icons8.com/?size=24&id=59810&format=png" alt="Examples"/> Example Questions

```
💡 "what was that email address?"
💡 "tracking number"
💡 "the code snippet from earlier"
💡 "paste image 2" (pastes the 2nd most recent image)
💡 "show me the link I copied yesterday"
💡 "find that API key"
```

---

## <img src="https://img.icons8.com/?size=32&id=60641&format=png" alt="Architecture"/> Architecture

### <img src="https://img.icons8.com/?size=24&id=87685&format=png" alt="Tech Stack"/> Tech Stack

<div align="center">

| Layer | Technology | Purpose |
|:------|:-----------|:--------|
| **<img src="https://img.icons8.com/?size=16&id=104086&format=png" alt="UI"/> UI Framework** | <img src="https://img.shields.io/badge/PyQt5-41CD52?style=flat-square&logo=qt&logoColor=white" alt="PyQt5"/> | Modern, responsive user interface |
| **<img src="https://img.icons8.com/?size=16&id=37410&format=png" alt="AI"/> AI Model** | <img src="https://img.shields.io/badge/Llama--3.2--1B-0467DF?style=flat-square&logo=meta&logoColor=white" alt="Llama"/> | Local AI inference for privacy |
| **<img src="https://img.icons8.com/?size=16&id=11360&format=png" alt="DB"/> Database** | <img src="https://img.shields.io/badge/SQLite-003B57?style=flat-square&logo=sqlite&logoColor=white" alt="SQLite"/> | Efficient data storage and retrieval |
| **<img src="https://img.icons8.com/?size=16&id=79020&format=png" alt="Clipboard"/> Clipboard API** | <img src="https://img.shields.io/badge/Windows_API-0078D6?style=flat-square&logo=windows&logoColor=white" alt="Windows API"/> | Windows clipboard integration |
| **<img src="https://img.icons8.com/?size=16&id=60677&format=png" alt="Hotkeys"/> Hotkey System** | <img src="https://img.shields.io/badge/pynput-keyboard-green?style=flat-square" alt="Pynput"/> | Global keyboard shortcuts |
| **<img src="https://img.icons8.com/?size=16&id=cEcenq1dEbND&format=png" alt="OCR"/> OCR Engine** | <img src="https://img.shields.io/badge/Tesseract-OCR-blue?style=flat-square" alt="Tesseract"/> | Text extraction from images |

</div>

### <img src="https://img.icons8.com/?size=24&id=843&format=png" alt="Structure"/> Project Structure

```
Clipit/
├── 📦 clipit/                  # Main application package
│   ├── 🚀 main.py              # Application entry point
│   ├── 🎨 ui/                  # User interface components
│   │   ├── floating_clippy.py  # Clippy assistant
│   │   ├── floating_dog.py     # Dog animation
│   │   ├── main_window.py      # Main application window
│   │   └── suggestions.py      # Suggestion system
│   ├── ⚙️ services/            # Core services
│   │   ├── ai_service.py       # AI integration
│   │   ├── clipboard_monitor.py # Clipboard tracking
│   │   ├── hotkey_manager.py   # Keyboard shortcuts
│   │   ├── ocr_service.py      # OCR functionality
│   │   └── text_capture.py     # Text capture system
│   ├── 💾 models/              # Database models
│   │   ├── database.py         # Database connection
│   │   └── item.py             # Data models
│   └── 🔧 utils/               # Utilities
├── 📋 requirements.txt         # Python dependencies
├── 🧪 test_clipit.py          # Test suite
├── 🪟 run.bat                 # Windows launcher
├── 📚 ARCHITECTURE.md         # Detailed architecture docs
├── 📖 README.md               # This file
└── 🔧 TROUBLESHOOTING.md      # Common issues & solutions
```

For detailed architecture diagrams and technical documentation, see **[<img src="https://img.icons8.com/?size=16&id=11074&format=png" alt="Docs"/> ARCHITECTURE.md](ARCHITECTURE.md)**.

---

## <img src="https://img.icons8.com/?size=32&id=77240&format=png" alt="Configuration"/> Configuration

ClipIt stores data in your Windows AppData folder:

```
%APPDATA%/Clipit/
├── clipit.db           # SQLite database
└── images/             # Copied images
```

---

## <img src="https://img.icons8.com/?size=32&id=58872&format=png" alt="Testing"/> Testing

ClipIt includes a comprehensive test suite to ensure reliability.

```bash
# Run all tests
python test_clipit.py
```

See **[<img src="https://img.icons8.com/?size=16&id=58872&format=png" alt="Testing"/> TESTING.md](TESTING.md)** for comprehensive testing procedures.

---

## <img src="https://img.icons8.com/?size=32&id=876&format=png" alt="Warning"/> Known Limitations

<table>
<tr>
<td width="50%">

**<img src="https://img.icons8.com/?size=20&id=37410&format=png" alt="AI"/> AI Model Size**
- Llama-3.2-1B is relatively small
- Complex queries may not work perfectly
- Trade-off for fast local inference

</td>
<td width="50%">

**<img src="https://img.icons8.com/?size=20&id=60006&format=png" alt="Image"/> Image Analysis**
- Limited image understanding
- Uses separate vision model if available
- Primarily focused on text content

</td>
</tr>
<tr>
<td width="50%">

**<img src="https://img.icons8.com/?size=20&id=cEcenq1dEbND&format=png" alt="OCR"/> OCR Quality**
- Depends on screen content clarity
- Affected by font sizes and styles
- Tesseract configuration matters

</td>
<td width="50%">

**<img src="https://img.icons8.com/?size=20&id=104086&format=png" alt="Security"/> Antivirus Software**
- May flag keyboard hooks
- False positive detection possible
- Add exception if needed

</td>
</tr>
</table>

---

## <img src="https://img.icons8.com/?size=32&id=417&format=png" alt="Bug"/> Troubleshooting

Having issues? Check out our comprehensive troubleshooting guide:

**[<img src="https://img.icons8.com/?size=20&id=11325&format=png" alt="Fix"/> TROUBLESHOOTING.md](TROUBLESHOOTING.md)**

Common issues include:
- Tesseract OCR not found
- Keyboard shortcuts not working
- AI model loading errors
- Antivirus blocking hotkeys

---

## <img src="https://img.icons8.com/?size=32&id=59800&format=png" alt="Contributing"/> Contributing

Contributions are welcome! We'd love your help to make ClipIt even better.

<div align="center">

**Ways to Contribute:**

| <img src="https://img.icons8.com/?size=24&id=417&format=png" alt="Bug"/> Report Bugs | <img src="https://img.icons8.com/?size=24&id=60003&format=png" alt="Feature"/> Request Features | <img src="https://img.icons8.com/?size=24&id=59875&format=png" alt="PR"/> Submit PRs | <img src="https://img.icons8.com/?size=24&id=59877&format=png" alt="Docs"/> Improve Docs |
|:-------------:|:------------------:|:------------:|:--------------:|
| [Open Issue](https://github.com/nihalnihalani/Clipit/issues) | [Feature Request](https://github.com/nihalnihalani/Clipit/issues) | [Pull Request](https://github.com/nihalnihalani/Clipit/pulls) | [Edit Docs](https://github.com/nihalnihalani/Clipit) |

</div>

---

## <img src="https://img.icons8.com/?size=32&id=24551&format=png" alt="License"/> License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## <img src="https://img.icons8.com/?size=32&id=59800&format=png" alt="Thanks"/> Acknowledgments

ClipIt wouldn't be possible without these amazing projects:

<div align="center">

| Project | Purpose |
|:--------|:--------|
| <img src="https://img.icons8.com/?size=20&id=37410&format=png" alt="Llama"/> **[Meta Llama-3.2](https://huggingface.co/meta-llama)** | Local AI language model |
| <img src="https://img.icons8.com/?size=20&id=cEcenq1dEbND&format=png" alt="OCR"/> **[Tesseract OCR](https://github.com/tesseract-ocr/tesseract)** | Optical character recognition |
| <img src="https://img.icons8.com/?size=20&id=104086&format=png" alt="PyQt"/> **[PyQt5](https://www.riverbankcomputing.com/software/pyqt/)** | Cross-platform GUI framework |
| <img src="https://img.icons8.com/?size=20&id=PGpXkTUdCHk8&format=png" alt="Dog"/> **[PastePup](https://github.com/BarathwajAnandan/pastepup)** | Original macOS/Swift inspiration |

</div>



---

<div align="center">

## <img src="https://img.icons8.com/?size=32&id=104&format=png" alt="Star"/> Star History

If you find ClipIt useful, please consider giving it a star!

[![Star History Chart](https://api.star-history.com/svg?repos=nihalnihalani/Clipit&type=Date)](https://star-history.com/#nihalnihalani/Clipit&Date)

---

### <img src="https://img.icons8.com/?size=24&id=59799&format=png" alt="Love"/> Made with care for productivity enthusiasts

<p>
  <img src="https://img.shields.io/badge/Made_with-❤️-red?style=for-the-badge" alt="Made with Love">
  <img src="https://img.shields.io/badge/Powered_by-AI-blue?style=for-the-badge" alt="Powered by AI">
  <img src="https://img.shields.io/badge/Built_for-Windows-0078D6?style=for-the-badge&logo=windows" alt="Built for Windows">
</p>

**[⬆ Back to Top](#-clipit)**

</div>
