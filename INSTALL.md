# Clipit Installation Guide

## System Requirements

- **Operating System:** Windows 10 or Windows 11
- **Python:** 3.8 or higher
- **RAM:** 4GB minimum (8GB recommended for AI model)
- **Disk Space:** 2GB for application and AI model

## Step-by-Step Installation

### 1. Install Python

Download Python from: https://www.python.org/downloads/

During installation:
- ✅ Check "Add Python to PATH"
- ✅ Check "Install pip"

Verify installation:
```bash
python --version
pip --version
```

### 2. Install Tesseract OCR

Download from: https://github.com/UB-Mannheim/tesseract/wiki

Recommended installation path: `C:\Program Files\Tesseract-OCR\`

**Important:** During installation, make sure to select "Add to PATH" option.

Verify installation:
```bash
tesseract --version
```

### 3. Install Clipit

#### Option A: From Source

```bash
# Clone or download the repository
cd clipit

# Install dependencies
pip install -r requirements.txt

# Run the application
python -m clipit.main
```

#### Option B: Using Virtual Environment (Recommended)

```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run the application
python -m clipit.main
```

### 4. First Run

On first run:
1. The AI model will download (1-2GB) - **this may take 5-15 minutes**
2. Database will be created at `%APPDATA%\Clipit\clipit.db`
3. Main window will appear
4. System tray icon will appear

**Note:** The first AI query may take 10-30 seconds as the model loads into memory.

## Troubleshooting Installation

### Python Not Found
```
'python' is not recognized as an internal or external command
```

**Solution:** Reinstall Python with "Add Python to PATH" checked, or add manually:
1. Open System Properties → Environment Variables
2. Add Python installation folder to PATH
3. Common paths: `C:\Python38\`, `C:\Users\YourName\AppData\Local\Programs\Python\Python38\`

### Tesseract Not Found
```
TesseractNotFoundError
```

**Solution:**
1. Verify Tesseract is installed
2. Add to PATH or edit `clipit/services/ocr_service.py` to point to tesseract.exe
3. Restart terminal after PATH changes

### Pip Install Fails

**PyWin32 Installation Error:**
```bash
# Try installing PyWin32 separately
pip install pywin32
python Scripts/pywin32_postinstall.py -install
```

**PyQt5 Installation Error:**
```bash
# Try installing PyQt5 separately
pip install PyQt5
```

**Torch Installation Error (Large Download):**
```bash
# Install CPU-only version (smaller)
pip install torch --index-url https://download.pytorch.org/whl/cpu
```

### Permission Errors

**Access Denied:**
- Run Command Prompt or PowerShell as Administrator
- Or install in virtual environment (doesn't require admin)

### Out of Memory During Model Load

**Error:** Model loading fails with memory error

**Solution:**
- Close other applications
- Ensure 4GB+ free RAM
- Edit `clipit/services/ai_service.py` to use a smaller model
- Consider using CPU-only torch (uses less RAM)

## Optional: Add to Windows Startup

### Method 1: Startup Folder

1. Press `Win + R`
2. Type `shell:startup` and press Enter
3. Create shortcut to `python -m clipit.main` in opened folder

### Method 2: Task Scheduler

1. Open Task Scheduler
2. Create Basic Task
3. Trigger: At log on
4. Action: Start a program
5. Program: `C:\Path\To\Python\python.exe`
6. Arguments: `-m clipit.main`
7. Start in: `C:\Path\To\Clipit\`

## Uninstallation

1. Stop the application
2. Delete the application folder
3. Delete `%APPDATA%\Clipit\` (contains database and images)
4. Remove from Startup (if added)

## Updating

```bash
cd clipit
git pull  # If using Git
pip install -r requirements.txt --upgrade
```

## Configuration

### Database Location
Default: `%APPDATA%\Clipit\clipit.db`

To change, edit `clipit/models/database.py`

### AI Model
Default: `meta-llama/Llama-3.2-1B`

To change, edit `clipit/services/ai_service.py`:
```python
def __init__(self, model_name="your-model-name"):
```

### Hotkeys
Current hotkeys are hardcoded:
- Alt+X: Text capture
- Alt+V: OCR
- Alt+S: Suggestions

To change, edit `clipit/services/hotkey_manager.py`

## Building Executable (Optional)

To create a standalone .exe file:

```bash
pip install pyinstaller

pyinstaller --name="Clipit" ^
            --onefile ^
            --windowed ^
            --icon=assets/icon.ico ^
            --add-data "assets;assets" ^
            clipit/main.py
```

The executable will be in `dist/Clipit.exe`

**Note:** Executable will be large (200-500MB) due to AI model.

## Known Issues

1. **Antivirus False Positives:** Some antivirus software flags keyboard hooks as suspicious. Add exception if needed.

2. **Windows Defender SmartScreen:** May block first run. Click "More info" → "Run anyway"

3. **High Memory Usage:** AI model uses 1-2GB RAM. This is normal.

4. **Slow First Query:** First AI query loads model into memory (10-30 seconds). Subsequent queries are faster.

5. **OCR Quality:** OCR accuracy depends on text clarity and font. Works best with clear, high-contrast text.

## Getting Help

- Check TESTING.md for common issues
- Review logs in terminal/console
- Check GitHub Issues (if applicable)
- Ensure all dependencies are up to date

## Security Notice

⚠️ **Important:** Clipit stores clipboard content in plain text in a local database. This includes:
- Passwords (if copied)
- API keys
- Private messages
- Sensitive data

**Recommendations:**
- Don't copy sensitive passwords (use password manager instead)
- Clear history regularly
- Encrypt your hard drive
- Don't share database file

