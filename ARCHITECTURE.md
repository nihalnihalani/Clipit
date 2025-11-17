# ClipIt Architecture

This document provides comprehensive architecture diagrams for the ClipIt Windows clipboard manager.

## System Overview

```mermaid
graph TB
    subgraph "User Interaction Layer"
        USER[👤 User]
        HOTKEYS[⌨️ Global Hotkeys<br/>Alt+X, Alt+V, Alt+S]
    end
    
    subgraph "UI Layer"
        MAIN[🪟 Main Window<br/>Clipboard History]
        FLOATING[🐕 Floating Dog<br/>Status Widget]
        SUGGESTIONS[💡 Suggestions Overlay<br/>Recent Items]
    end
    
    subgraph "Service Layer"
        CLIPBOARD[📋 Clipboard Monitor<br/>Background Thread]
        TEXTCAP[⌨️ Text Capture<br/>Keyboard Listener]
        OCR[👁️ OCR Service<br/>Tesseract]
        AI[🤖 AI Service<br/>Llama-3.2-1B]
        HOTKEY_MGR[🎮 Hotkey Manager<br/>Global Hooks]
    end
    
    subgraph "Data Layer"
        DB[(💾 SQLite Database<br/>clipit.db)]
        IMAGES[🖼️ Image Storage<br/>images/]
    end
    
    subgraph "External APIs"
        WIN_CLIP[🪟 Windows Clipboard<br/>win32clipboard]
        WIN_API[🪟 Windows API<br/>Process Info]
        TESSERACT[📖 Tesseract OCR<br/>Engine]
    end
    
    USER -->|Types/Clicks| HOTKEYS
    USER -->|Views History| MAIN
    
    HOTKEYS --> HOTKEY_MGR
    HOTKEY_MGR -->|Alt+X| TEXTCAP
    HOTKEY_MGR -->|Alt+V| OCR
    HOTKEY_MGR -->|Alt+S| SUGGESTIONS
    
    CLIPBOARD -->|Poll 500ms| WIN_CLIP
    CLIPBOARD -->|Get App Info| WIN_API
    CLIPBOARD -->|Save| DB
    CLIPBOARD -->|Generate Tags| AI
    
    TEXTCAP -->|Capture Question| AI
    TEXTCAP -->|Replace Text| USER
    TEXTCAP -->|Show Status| FLOATING
    
    OCR -->|Screenshot| WIN_API
    OCR -->|Extract Text| TESSERACT
    OCR -->|Save Text| DB
    OCR -->|Show Status| FLOATING
    
    AI -->|Query History| DB
    AI -->|Generate Answer| TEXTCAP
    AI -->|Generate Tags| DB
    
    MAIN -->|Read History| DB
    MAIN -->|Search Items| DB
    SUGGESTIONS -->|Read Items| DB
    
    DB -->|Store Images| IMAGES
    
    style USER fill:#e1f5ff
    style AI fill:#ffe1e1
    style DB fill:#e1ffe1
    style WIN_CLIP fill:#fff4e1
    style WIN_API fill:#fff4e1
    style TESSERACT fill:#fff4e1
```

## Component Architecture

```mermaid
graph LR
    subgraph "clipit Package"
        MAIN[main.py<br/>Application Entry]
        
        subgraph "models/"
            DB_INIT[database.py<br/>SQLAlchemy Setup]
            ITEM[item.py<br/>Item Model]
        end
        
        subgraph "services/"
            CLIP_MON[clipboard_monitor.py<br/>Clipboard Service]
            AI_SVC[ai_service.py<br/>AI Service]
            TEXT_CAP[text_capture.py<br/>Text Capture]
            OCR_SVC[ocr_service.py<br/>OCR Service]
            HOTKEY[hotkey_manager.py<br/>Hotkey Manager]
        end
        
        subgraph "ui/"
            MAIN_WIN[main_window.py<br/>Main Window]
            FLOAT[floating_clippy.py<br/>Floating Widget]
            SUGG[suggestions.py<br/>Suggestions UI]
        end
        
        subgraph "utils/"
            UTILS[Utility Functions]
        end
    end
    
    MAIN --> DB_INIT
    MAIN --> CLIP_MON
    MAIN --> AI_SVC
    MAIN --> TEXT_CAP
    MAIN --> OCR_SVC
    MAIN --> HOTKEY
    MAIN --> MAIN_WIN
    MAIN --> FLOAT
    MAIN --> SUGG
    
    CLIP_MON --> DB_INIT
    CLIP_MON --> ITEM
    CLIP_MON --> AI_SVC
    
    AI_SVC --> ITEM
    TEXT_CAP --> AI_SVC
    OCR_SVC --> DB_INIT
    
    MAIN_WIN --> CLIP_MON
    MAIN_WIN --> AI_SVC
    SUGG --> DB_INIT
    
    style MAIN fill:#ff6b6b
    style AI_SVC fill:#4ecdc4
    style DB_INIT fill:#95e1d3
    style CLIP_MON fill:#f38181
```

## Data Flow - Text Capture & AI Answer

```mermaid
sequenceDiagram
    participant User
    participant HotkeyManager
    participant TextCapture
    participant FloatingDog
    participant AIService
    participant Database
    participant ClipboardMonitor
    
    User->>HotkeyManager: Press Alt+X
    HotkeyManager->>TextCapture: start_capturing()
    TextCapture->>FloatingDog: show("Listening...")
    FloatingDog->>User: Display dog widget
    
    User->>TextCapture: Types "tracking number"
    TextCapture->>TextCapture: Capture keystrokes
    
    User->>HotkeyManager: Press Alt+X again
    HotkeyManager->>TextCapture: stop_capturing()
    TextCapture->>FloatingDog: update("Thinking...")
    
    TextCapture->>ClipboardMonitor: get_recent_items(10)
    ClipboardMonitor->>Database: Query last 10 items
    Database-->>ClipboardMonitor: Return items
    ClipboardMonitor-->>TextCapture: Items with tags
    
    TextCapture->>AIService: generate_answer(question, context)
    AIService->>AIService: Build prompt
    AIService->>AIService: Run Llama model
    AIService->>AIService: Parse JSON response
    AIService-->>TextCapture: "UPS-12345-ABC"
    
    TextCapture->>TextCapture: Select all text (Ctrl+A)
    TextCapture->>TextCapture: Delete text
    TextCapture->>User: Type answer "UPS-12345-ABC"
    
    TextCapture->>FloatingDog: update("Answer ready! 🎉")
    
    Note over User: Answer replaces question<br/>Ready to paste!
```

## Data Flow - Clipboard Monitoring

```mermaid
sequenceDiagram
    participant User
    participant App as External App<br/>(Chrome, Word, etc)
    participant WindowsClipboard
    participant ClipboardMonitor
    participant WindowsAPI
    participant Database
    participant AIService
    
    User->>App: Ctrl+C (Copy)
    App->>WindowsClipboard: Set clipboard data
    
    loop Every 500ms
        ClipboardMonitor->>WindowsAPI: GetForegroundWindow()
        WindowsAPI-->>ClipboardMonitor: Window handle
        
        ClipboardMonitor->>WindowsAPI: GetWindowThreadProcessId()
        WindowsAPI-->>ClipboardMonitor: Process ID
        
        ClipboardMonitor->>WindowsAPI: Process.name()
        WindowsAPI-->>ClipboardMonitor: "chrome.exe"
        
        ClipboardMonitor->>WindowsClipboard: OpenClipboard()
        ClipboardMonitor->>WindowsClipboard: GetClipboardData()
        WindowsClipboard-->>ClipboardMonitor: "john@example.com"
        ClipboardMonitor->>WindowsClipboard: CloseClipboard()
        
        alt New content detected
            ClipboardMonitor->>Database: Check for duplicates
            Database-->>ClipboardMonitor: Not duplicate
            
            ClipboardMonitor->>Database: Create Item(content, app_name, timestamp)
            Database-->>ClipboardMonitor: Item ID: 123
            
            ClipboardMonitor->>AIService: generate_tags(content, app_name)
            Note over AIService: Background thread
            AIService->>AIService: Run Llama model
            AIService-->>ClipboardMonitor: ["email", "contact"]
            
            ClipboardMonitor->>Database: Update Item.tags
        end
    end
```

## Database Schema

```mermaid
erDiagram
    ITEMS {
        integer id PK
        string content
        datetime timestamp
        string app_name
        string window_title
        string content_type
        json tags
        string image_path
    }
    
    ITEMS ||--o{ TAGS : has
    ITEMS ||--o| IMAGE_FILES : references
    
    TAGS {
        string tag_name
        integer item_id FK
    }
    
    IMAGE_FILES {
        string filename
        string path
        datetime created
    }
```

## State Machine - Text Capture

```mermaid
stateDiagram-v2
    [*] --> Idle
    
    Idle --> Listening : Alt+X pressed
    Listening --> Listening : User types characters
    Listening --> Processing : Alt+X pressed again
    Listening --> Idle : ESC pressed
    
    Processing --> Querying : Captured text ready
    Querying --> Generating : Got clipboard context
    Generating --> Replacing : AI answer generated
    Replacing --> Complete : Text replaced
    
    Complete --> Idle : After 3 seconds
    
    note right of Listening
        Floating dog: "Listening..."
        Recording keystrokes
    end note
    
    note right of Processing
        Floating dog: "Thinking..."
        Stop keyboard capture
    end note
    
    note right of Querying
        Query last 10 clipboard items
        Build context for AI
    end note
    
    note right of Generating
        Run Llama-3.2-1B model
        Parse JSON response
    end note
    
    note right of Replacing
        Ctrl+A → Select all
        Backspace → Delete
        Type AI answer
    end note
```

## Thread Architecture

```mermaid
graph TB
    subgraph "Main Thread (Qt Event Loop)"
        QT[Qt Application]
        MAIN_UI[Main Window]
        FLOAT_UI[Floating Dog]
        SUGG_UI[Suggestions]
    end
    
    subgraph "Background Thread 1"
        CLIP_MON[Clipboard Monitor Loop<br/>Runs every 500ms]
    end
    
    subgraph "Background Thread 2"
        HOTKEY_LISTEN[Hotkey Listener<br/>pynput listener]
    end
    
    subgraph "Background Thread 3"
        TEXT_LISTEN[Text Capture Listener<br/>pynput keyboard]
    end
    
    subgraph "Async Thread Pool"
        TAG_GEN1[Tag Generation Task 1]
        TAG_GEN2[Tag Generation Task 2]
        TAG_GEN3[Tag Generation Task 3]
    end
    
    QT --> MAIN_UI
    QT --> FLOAT_UI
    QT --> SUGG_UI
    
    CLIP_MON -->|Emit Signal| QT
    HOTKEY_LISTEN -->|Callback| QT
    TEXT_LISTEN -->|Callback| QT
    
    CLIP_MON -->|Spawn| TAG_GEN1
    CLIP_MON -->|Spawn| TAG_GEN2
    CLIP_MON -->|Spawn| TAG_GEN3
    
    style QT fill:#ff6b6b
    style CLIP_MON fill:#4ecdc4
    style HOTKEY_LISTEN fill:#95e1d3
    style TEXT_LISTEN fill:#f9ca24
```

## Technology Stack Layers

```mermaid
graph TB
    subgraph "Application Layer"
        APP[ClipIt Application<br/>main.py]
    end
    
    subgraph "UI Framework Layer"
        PYQT5[PyQt5<br/>Windows, Widgets, Signals]
        SYSTRAY[System Tray Integration]
    end
    
    subgraph "Business Logic Layer"
        SERVICES[Services<br/>Clipboard, AI, OCR, Text Capture]
        MODELS[Data Models<br/>SQLAlchemy ORM]
    end
    
    subgraph "AI/ML Layer"
        TRANSFORMERS[Hugging Face Transformers<br/>Model loading & inference]
        TORCH[PyTorch<br/>Neural network runtime]
        LLAMA[Llama-3.2-1B Model<br/>1B parameters]
    end
    
    subgraph "Data Persistence Layer"
        SQLALCHEMY[SQLAlchemy ORM]
        SQLITE[SQLite Database]
        FILESYSTEM[File System<br/>Image storage]
    end
    
    subgraph "System Integration Layer"
        PYWIN32[pywin32<br/>Windows API access]
        PYNPUT[pynput<br/>Keyboard & mouse hooks]
        PYTESSERACT[pytesseract<br/>OCR wrapper]
        PYAUTOGUI[pyautogui<br/>GUI automation]
        PSUTIL[psutil<br/>Process utilities]
    end
    
    subgraph "Operating System Layer"
        WINDOWS[Windows 10/11<br/>Clipboard API, Window Manager]
        TESSERACT_ENGINE[Tesseract OCR Engine]
    end
    
    APP --> PYQT5
    APP --> SERVICES
    
    PYQT5 --> SYSTRAY
    SERVICES --> MODELS
    SERVICES --> TRANSFORMERS
    SERVICES --> PYWIN32
    SERVICES --> PYNPUT
    SERVICES --> PYTESSERACT
    SERVICES --> PYAUTOGUI
    SERVICES --> PSUTIL
    
    MODELS --> SQLALCHEMY
    SQLALCHEMY --> SQLITE
    SERVICES --> FILESYSTEM
    
    TRANSFORMERS --> TORCH
    TRANSFORMERS --> LLAMA
    
    PYWIN32 --> WINDOWS
    PYNPUT --> WINDOWS
    PYTESSERACT --> TESSERACT_ENGINE
    PYAUTOGUI --> WINDOWS
    PSUTIL --> WINDOWS
    
    SQLITE --> WINDOWS
    FILESYSTEM --> WINDOWS
    TESSERACT_ENGINE --> WINDOWS
    
    style APP fill:#ff6b6b
    style SERVICES fill:#4ecdc4
    style LLAMA fill:#ffe66d
    style WINDOWS fill:#a8dadc
```

## Deployment View

```mermaid
graph TB
    subgraph "User's Windows Machine"
        subgraph "Python Environment"
            CLIPIT[ClipIt Application<br/>Python 3.8+]
            VENV[Virtual Environment<br/>Dependencies]
        end
        
        subgraph "User Data Directory"
            APPDATA["%APPDATA%/Clipit/"]
            DATABASE[(clipit.db<br/>SQLite)]
            IMAGES[images/<br/>PNG files]
        end
        
        subgraph "Model Cache"
            HUGGINGFACE["~/.cache/huggingface/<br/>Llama-3.2-1B (~2GB)"]
        end
        
        subgraph "External Software"
            TESSERACT[Tesseract OCR<br/>Installed separately]
        end
        
        subgraph "System Resources"
            RAM[RAM: 2-4GB used]
            CPU[CPU: 10-50% during AI]
            GPU[GPU: Optional acceleration]
        end
    end
    
    CLIPIT --> VENV
    CLIPIT --> APPDATA
    APPDATA --> DATABASE
    APPDATA --> IMAGES
    CLIPIT --> HUGGINGFACE
    CLIPIT --> TESSERACT
    CLIPIT --> RAM
    CLIPIT --> CPU
    CLIPIT -.->|If available| GPU
    
    style CLIPIT fill:#ff6b6b
    style DATABASE fill:#95e1d3
    style HUGGINGFACE fill:#ffe66d
```

## File Structure

```
PastePup/
├── clipit/                          # Main application package
│   ├── __init__.py                 # Package initializer
│   ├── main.py                     # Application entry point & orchestration
│   │
│   ├── models/                     # Data layer
│   │   ├── __init__.py
│   │   ├── database.py            # SQLAlchemy setup & session management
│   │   └── item.py                # Item model (clipboard entries)
│   │
│   ├── services/                   # Business logic layer
│   │   ├── __init__.py
│   │   ├── clipboard_monitor.py   # Background clipboard monitoring
│   │   ├── ai_service.py          # Llama AI integration
│   │   ├── text_capture.py        # Keyboard capture & text replacement
│   │   ├── ocr_service.py         # Tesseract OCR integration
│   │   └── hotkey_manager.py      # Global hotkey hooks
│   │
│   ├── ui/                         # Presentation layer
│   │   ├── __init__.py
│   │   ├── main_window.py         # Main application window (PyQt5)
│   │   ├── floating_clippy.py     # Floating status widget
│   │   └── suggestions.py         # Suggestions overlay
│   │
│   └── utils/                      # Utilities
│       └── __init__.py
│
├── requirements.txt                # Python dependencies
├── test_clipit.py                 # Test suite
├── run.bat                        # Windows launcher script
│
├── README.md                      # User documentation
├── ARCHITECTURE.md                # This file
├── INSTALL.md                     # Installation guide
├── TESTING.md                     # Testing procedures
├── TROUBLESHOOTING.md            # Common issues
├── STATUS.md                      # Project status
└── MIGRATION_SUMMARY.md          # Migration history
```

## Key Design Patterns

### 1. Observer Pattern
- **Where**: Clipboard monitoring
- **How**: Background thread continuously polls clipboard, notifies when changes detected

### 2. Service Layer Pattern
- **Where**: All business logic in `services/`
- **How**: Separation of concerns - UI, business logic, and data layers are independent

### 3. Repository Pattern
- **Where**: Database access through SQLAlchemy
- **How**: Abstract data access, easy to swap database implementations

### 4. Facade Pattern
- **Where**: AIService wraps complex Transformers/PyTorch APIs
- **How**: Simple interface (`generate_answer()`, `generate_tags()`) hides complexity

### 5. Strategy Pattern
- **Where**: AI model selection (can swap Llama for other models)
- **How**: Model name configurable, same interface for all models

### 6. Signal-Slot Pattern
- **Where**: PyQt5 UI updates
- **How**: Asynchronous communication between threads and UI

## Performance Considerations

### Memory Usage
```
Idle State:           ~200 MB
Model Loaded:         ~2 GB
Active Processing:    ~2.5 GB
Peak (with GPU):      ~3 GB
```

### Timing Metrics
```
Clipboard Check:      <1 ms (every 500ms)
Database Save:        5-10 ms
Tag Generation:       1-3 seconds (async)
AI Answer:            1-3 seconds (CPU), <1s (GPU)
OCR Processing:       1-3 seconds
Text Replacement:     <100 ms
```

### Threading Model
- **Main Thread**: Qt event loop (UI updates)
- **Background Thread 1**: Clipboard monitoring (continuous)
- **Background Thread 2**: Hotkey listener (event-driven)
- **Background Thread 3**: Text capture (when active)
- **Thread Pool**: AI tag generation (spawned per item)

## Security Architecture

```mermaid
graph TB
    subgraph "Attack Surface"
        CLIPBOARD[Clipboard Data<br/>Contains sensitive info]
        DATABASE[Unencrypted Database<br/>Plain text storage]
        KEYBOARD[Keyboard Hooks<br/>Could be flagged as keylogger]
    end
    
    subgraph "Mitigations"
        LOCAL[Fully Offline<br/>No network calls]
        APPDATA[Protected Directory<br/>%APPDATA%/Clipit/]
        READONLY[Read-only clipboard<br/>Never writes to it]
    end
    
    subgraph "Risks"
        MALWARE[⚠️ Antivirus may flag<br/>keyboard hooks]
        PASSWORD[⚠️ Passwords stored<br/>in plain text]
        SHARING[⚠️ Database contains<br/>all copied data]
    end
    
    CLIPBOARD --> DATABASE
    KEYBOARD --> MALWARE
    DATABASE --> PASSWORD
    DATABASE --> SHARING
    
    LOCAL -.->|Mitigates| SHARING
    APPDATA -.->|Protects| DATABASE
    READONLY -.->|Reduces risk| CLIPBOARD
    
    style MALWARE fill:#ff6b6b
    style PASSWORD fill:#ff6b6b
    style SHARING fill:#ff6b6b
    style LOCAL fill:#95e1d3
```

## Future Enhancements

```mermaid
mindmap
  root((ClipIt<br/>Future))
    Encryption
      AES-256 for database
      Master password
      Secure password fields
    Cloud Sync
      Optional cloud backup
      Multi-device sync
      Encrypted transmission
    Advanced Search
      Full-text search
      Regex support
      Date range filters
      Tag-based filtering
    Better AI
      Llama-3.2-3B upgrade
      GPU acceleration
      Image analysis (BLIP)
      Voice queries
    UI Improvements
      Dark mode
      Custom themes
      Configurable hotkeys
      History timeline view
    Performance
      Model quantization (4-bit)
      Lazy loading
      Virtual scrolling
      Caching layer
    Integrations
      Browser extension
      Office add-in
      Mobile companion
      API for developers
```

## Monitoring & Logging

Current logging strategy:
```python
# All components log to console
print("✅ Success message")
print("⚠️ Warning message")
print("❌ Error message")
print("🚀 Startup message")
print("📋 Clipboard activity")
print("🤖 AI activity")
```

Recommended production logging:
```python
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('%APPDATA%/Clipit/clipit.log'),
        logging.StreamHandler()
    ]
)
```

---

## Useful Commands

### Generate visual diagram from Mermaid:
```bash
# Install mermaid-cli
npm install -g @mermaid-js/mermaid-cli

# Generate PNG
mmdc -i ARCHITECTURE.md -o architecture.png

# Generate SVG
mmdc -i ARCHITECTURE.md -o architecture.svg
```

### Analyze code structure:
```bash
# Line counts
find clipit -name "*.py" | xargs wc -l

# Dependency graph
pydeps clipit --max-bacon=2 -o dependencies.svg
```

### Profile performance:
```bash
# Memory profiling
python -m memory_profiler clipit/main.py

# CPU profiling
python -m cProfile -o profile.stats clipit/main.py
```

---

**Last Updated**: 2025-11-16  
**Version**: 1.0  
**Author**: ClipIt Team

