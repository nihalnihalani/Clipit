# Clipit Troubleshooting Guide

## Installation Issues

### Python Not Found

**Symptoms:**
```
'python' is not recognized as an internal or external command
```

**Solutions:**
1. Verify Python installation:
   ```bash
   where python
   ```

2. Add Python to PATH:
   - Open System Properties → Advanced → Environment Variables
   - Add Python folder to PATH
   - Restart terminal

3. Use full path to Python:
   ```bash
   C:\Python38\python.exe -m clipit.main
   ```

### Pip Install Fails

**Error:** `Failed building wheel for X`

**Solutions:**
1. Update pip:
   ```bash
   python -m pip install --upgrade pip
   ```

2. Install Visual C++ Build Tools (for some packages):
   Download from: https://visualstudio.microsoft.com/visual-cpp-build-tools/

3. Try installing problematic package separately:
   ```bash
   pip install pywin32
   pip install PyQt5
   pip install torch
   ```

### PyTorch Download Too Large

**Solution:** Install CPU-only version:
```bash
pip uninstall torch
pip install torch --index-url https://download.pytorch.org/whl/cpu
```

## Runtime Issues

### Application Won't Start

**Check 1: Python Version**
```bash
python --version
# Should be 3.8 or higher
```

**Check 2: Dependencies Installed**
```bash
pip list | findstr PyQt5
pip list | findstr pywin32
```

**Check 3: Run with Verbose Output**
```bash
python -m clipit.main 2>&1 | tee clipit.log
```

### Hotkeys Not Working

**Issue:** Alt+X, Alt+V, Alt+S don't respond

**Solutions:**
1. **Run as Administrator:**
   - Right-click → Run as Administrator

2. **Check for Conflicting Software:**
   - Disable other hotkey programs
   - Check AutoHotkey scripts
   - Check gaming software (Logitech, Razer, etc.)

3. **Try Alternative Keys:**
   Edit `clipit/services/hotkey_manager.py`:
   ```python
   # Change 'x' to 'q', 'v' to 'w', etc.
   if key.char == 'q':  # Instead of 'x'
   ```

4. **Windows Permissions:**
   - Some apps block global hotkeys
   - Try in different application (e.g., Notepad)

### AI Model Fails to Load

**Error:** `OutOfMemoryError` or model loading hangs

**Solutions:**
1. **Close Other Applications:**
   - AI model needs 2-4GB RAM
   - Close Chrome, video games, etc.

2. **Use Smaller Model:**
   Edit `clipit/services/ai_service.py`:
   ```python
   # Change to smaller model
   def __init__(self, model_name="distilgpt2"):  # Much smaller
   ```

3. **Increase Virtual Memory:**
   - System Properties → Advanced → Performance → Settings
   - Advanced → Virtual Memory → Change
   - Set to 8GB+

4. **Download Model Manually:**
   ```python
   from transformers import AutoModelForCausalLM
   model = AutoModelForCausalLM.from_pretrained("meta-llama/Llama-3.2-1B")
   ```

### OCR Not Working

**Error:** `TesseractNotFoundError`

**Solutions:**
1. **Install Tesseract:**
   https://github.com/UB-Mannheim/tesseract/wiki

2. **Set Tesseract Path:**
   Edit `clipit/services/ocr_service.py`:
   ```python
   pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'
   ```

3. **Verify Installation:**
   ```bash
   tesseract --version
   ```

**Error:** OCR extracts gibberish

**Solutions:**
- Use clear, high-contrast text
- Increase screen DPI
- Try different OCR settings in code
- Use Alt+V on pages with larger text

### Clipboard Monitoring Stops

**Symptoms:** New clipboard items don't appear in history

**Solutions:**
1. **Check Monitoring Status:**
   - Main window should show "Status: Monitoring"
   - Click "Start Monitoring" if stopped

2. **Restart Application:**
   - Exit completely (including system tray)
   - Relaunch

3. **Check Windows Clipboard:**
   - Press Win+V (Clipboard History)
   - If Windows clipboard is broken, restart Windows

4. **Database Issues:**
   - Close application
   - Delete `%APPDATA%\Clipit\clipit.db`
   - Restart (will recreate database)

### Floating Dog Won't Appear

**Solutions:**
1. **Check Display Settings:**
   - May be off-screen on multi-monitor setup
   - Disconnect extra monitors temporarily

2. **Force Show:**
   Edit `clipit/ui/floating_dog.py`:
   ```python
   # Change position
   x = 100  # Instead of screen.width() - self.width()
   y = 100  # Instead of 20
   ```

3. **Disable Transparency:**
   Comment out in `floating_dog.py`:
   ```python
   # self.setAttribute(Qt.WA_TranslucentBackground)
   ```

### Text Capture Doesn't Work

**Issue:** Alt+X doesn't capture typed text

**Solutions:**
1. **Test in Notepad First:**
   - Simpler application, fewer conflicts
   - If works in Notepad, issue is app-specific

2. **Check Keyboard Layout:**
   - Some non-US layouts may have issues
   - Try US keyboard layout

3. **Disable Text Prediction:**
   - Some apps with autocomplete interfere
   - Disable in app settings

4. **Use Alternative Method:**
   - Select text manually
   - Use Ctrl+C to copy
   - Use Alt+S for suggestions

## Performance Issues

### High CPU Usage

**Solutions:**
1. **Clipboard Polling Interval:**
   Edit `clipit/services/clipboard_monitor.py`:
   ```python
   time.sleep(1.0)  # Instead of 0.5 (check every 1 second)
   ```

2. **Disable AI Tagging:**
   Comment out in `clipboard_monitor.py`:
   ```python
   # threading.Thread(target=self._generate_tags_async, ...).start()
   ```

3. **Limit History Size:**
   Regularly clear old items

### High Memory Usage

**Normal:** 1-2GB with AI model loaded

**Solutions if Higher:**
1. **Clear History:**
   - Removes old items from memory

2. **Restart Application:**
   - Clears any memory leaks

3. **Use Smaller Model:**
   - See "AI Model Fails to Load" above

### Slow AI Responses

**First Query:** 10-30 seconds (model loading) - **Normal**

**Subsequent Queries:** Should be 1-3 seconds

**If All Queries Slow:**
1. **Use GPU if Available:**
   - Install CUDA
   - Install GPU-enabled PyTorch
   - Model will auto-detect GPU

2. **Reduce Context Size:**
   Edit `clipit/main.py`:
   ```python
   items = self.clipboard_monitor.get_recent_items(limit=5)  # Instead of 10
   ```

3. **Use Smaller Max Tokens:**
   Edit `clipit/services/ai_service.py`:
   ```python
   max_new_tokens=128,  # Instead of 256
   ```

## Database Issues

### Database Corrupted

**Error:** `database disk image is malformed`

**Solution:**
```bash
# Backup if needed
copy %APPDATA%\Clipit\clipit.db %APPDATA%\Clipit\clipit.db.backup

# Delete corrupted database
del %APPDATA%\Clipit\clipit.db

# Restart application (will recreate)
```

### Can't Delete Database

**Error:** Database file in use

**Solution:**
1. Exit Clipit completely (check system tray)
2. End Python processes in Task Manager
3. Try deleting again

### Migration Needed

If you update Clipit and database schema changes:

```bash
# Backup current database
copy %APPDATA%\Clipit\clipit.db %APPDATA%\Clipit\clipit.db.backup

# Delete old database (will lose history)
del %APPDATA%\Clipit\clipit.db

# Or manually migrate (advanced)
```

## Windows-Specific Issues

### Antivirus Blocking

**Symptoms:** Application won't run, keyboard hooks fail

**Solutions:**
1. **Add Exception:**
   - Add Python folder to antivirus exceptions
   - Add Clipit folder to exceptions

2. **Temporarily Disable:**
   - Disable antivirus temporarily
   - If works, issue is antivirus
   - Re-enable and add exceptions

3. **Windows Defender:**
   - Windows Security → Virus & threat protection
   - Manage settings → Add exclusion
   - Add Python and Clipit folders

### SmartScreen Blocks Execution

**Message:** "Windows protected your PC"

**Solution:**
- Click "More info"
- Click "Run anyway"

### UAC Prompts

**Issue:** Constant UAC prompts for Admin

**Solutions:**
1. **Don't Run as Admin:**
   - Not required unless hotkeys fail
   - Try without first

2. **Disable UAC for This App:**
   - Properties → Compatibility
   - Run as Administrator (permanent)

### Multiple Monitor Issues

**Issue:** Floating dog appears on wrong screen

**Solution:**
Edit `clipit/ui/floating_dog.py`:
```python
# Use specific screen
from PyQt5.QtWidgets import QApplication
screens = QApplication.screens()
screen = screens[0]  # Change index for different monitor
```

## Network Issues

### Model Download Fails

**Error:** Connection timeout during model download

**Solutions:**
1. **Check Internet Connection:**
   ```bash
   ping huggingface.co
   ```

2. **Use Different Network:**
   - Try mobile hotspot
   - Try different Wi-Fi

3. **Manual Download:**
   ```python
   # Use Python to download manually
   from transformers import AutoModelForCausalLM
   model = AutoModelForCausalLM.from_pretrained(
       "meta-llama/Llama-3.2-1B",
       resume_download=True  # Resume if interrupted
   )
   ```

4. **Use Proxy:**
   ```python
   # Set proxy in code if needed
   import os
   os.environ['HTTP_PROXY'] = 'http://proxy.example.com:8080'
   os.environ['HTTPS_PROXY'] = 'http://proxy.example.com:8080'
   ```

## Getting Debug Information

### Enable Verbose Logging

Create `clipit_debug.bat`:
```batch
@echo off
set PYTHONUNBUFFERED=1
python -m clipit.main > clipit_debug.log 2>&1
```

### Check System Information

```bash
# Python version
python --version

# Installed packages
pip list

# System info
systeminfo

# Available memory
wmic OS get FreePhysicalMemory
```

### Capture Error Screenshots

1. Run application
2. Trigger error
3. Take screenshot (Win + Shift + S)
4. Save terminal output

## Still Having Issues?

1. **Check Logs:**
   - Review terminal output
   - Look for ERROR or WARNING messages

2. **Test Individual Components:**
   ```python
   # Test AI service
   from clipit.services.ai_service import AIService
   ai = AIService()
   
   # Test clipboard
   import win32clipboard
   win32clipboard.OpenClipboard()
   data = win32clipboard.GetClipboardData()
   win32clipboard.CloseClipboard()
   print(data)
   ```

3. **Minimal Reproduction:**
   - Start with fresh virtual environment
   - Install only required packages
   - Test basic functionality

4. **Report Issue:**
   - Include error messages
   - Include system information
   - Include steps to reproduce
   - Include logs

