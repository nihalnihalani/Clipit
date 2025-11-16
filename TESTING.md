# Clipit Testing Guide

## Prerequisites

### 1. Install Python Dependencies

```bash
cd clipit
pip install -r requirements.txt
```

### 2. Install Tesseract OCR

Download and install from: https://github.com/UB-Mannheim/tesseract/wiki

Make sure Tesseract is in your PATH or installed at:
- `C:\Program Files\Tesseract-OCR\tesseract.exe`
- `C:\Program Files (x86)\Tesseract-OCR\tesseract.exe`

### 3. Run the Application

```bash
python -m clipit.main
```

## Testing Checklist

### ✅ Basic Functionality

- [ ] **Application Startup**
  - Application starts without errors
  - Main window appears
  - System tray icon appears
  - Database is created in `%APPDATA%\Clipit\`

- [ ] **Clipboard Monitoring**
  - Copy text to clipboard - should appear in history
  - Copy image to clipboard - should appear in history with image indicator
  - Duplicate content is not added twice
  - App name is captured correctly
  - Timestamps are accurate

### ⌨️ Hotkey Functionality

- [ ] **Alt+X (Text Capture & AI Answer)**
  - Press Alt+X → Floating dog appears with "Clipit is listening..."
  - Type a question (e.g., "what was that email address?")
  - Press Alt+X again → Dog shows "Clipit is thinking..."
  - AI generates answer and replaces your text
  - Dog auto-hides after 2 seconds

- [ ] **Alt+V (Screen OCR)**
  - Open a document or webpage with text
  - Press Alt+V → Dog shows "Extracting text from screen..."
  - OCR extracts text from screen
  - Extracted text appears in clipboard history
  - Success message appears

- [ ] **Alt+S (Suggestions)**
  - Copy several items to clipboard
  - Press Alt+S → Suggestions overlay appears
  - Arrow keys navigate suggestions
  - Enter key pastes selected item
  - ESC dismisses overlay
  - Number keys (1-9) select items

- [ ] **ESC Key**
  - ESC dismisses floating dog
  - ESC dismisses suggestions overlay

### 🤖 AI Service

- [ ] **Model Loading**
  - AI model loads successfully (may take 2-5 minutes first time)
  - Model status shown in main window
  - GPU detected if available (faster)

- [ ] **Answer Generation**
  - Questions about clipboard content return relevant answers
  - Answers are concise and direct
  - Irrelevant questions return empty/not found message
  - Answers don't include preamble like "The answer is..."

- [ ] **Tag Generation**
  - Clipboard items automatically get semantic tags
  - Tags are relevant to content
  - 3-7 tags generated per item
  - Tags are lowercase

### 🖥️ UI Functionality

- [ ] **Main Window**
  - Clipboard history displayed correctly
  - Refresh button updates list
  - Double-click item copies to clipboard
  - Clear History button works (with confirmation)
  - Start/Stop Monitoring button toggles correctly
  - Window minimizes to tray on close

- [ ] **System Tray**
  - Tray icon appears
  - Right-click shows menu
  - "Show Window" restores from tray
  - "Quit" closes application
  - Double-click tray icon shows window

- [ ] **Floating Dog**
  - Appears in top-right corner
  - Shows correct messages
  - Loading animation works
  - Auto-hides after completion
  - ESC dismisses dog

- [ ] **Suggestions Overlay**
  - Appears in bottom-left corner
  - Shows recent clipboard items
  - Keyboard navigation works
  - Mouse clicks work
  - Shows app names and tags

### 🔍 OCR Testing

- [ ] **Text Extraction**
  - Open Notepad with clear text
  - Press Alt+V
  - Text is extracted correctly
  - Extracted text appears in history

- [ ] **Different Content Types**
  - Test with PDF documents
  - Test with web pages
  - Test with images containing text
  - Test with code snippets

### 📋 Clipboard Content Types

- [ ] **Plain Text**
  - Short text (< 50 chars)
  - Long text (> 500 chars)
  - Multi-line text
  - Unicode characters
  - Special characters

- [ ] **Code**
  - Python code
  - JavaScript code
  - SQL queries
  - Terminal commands

- [ ] **Images**
  - Screenshots
  - Copied images from browser
  - Images from Paint/Photoshop

- [ ] **URLs**
  - Web URLs
  - File paths
  - Email addresses

### 🎯 Integration Testing

- [ ] **Cross-App Workflow**
  1. Copy email address from Chrome
  2. Copy code snippet from VS Code
  3. Copy tracking number from Notepad
  4. Press Alt+X and ask "tracking number"
  5. Verify correct answer is returned

- [ ] **Text Capture in Different Apps**
  - Test in Notepad
  - Test in Microsoft Word
  - Test in browser text fields
  - Test in Slack/Discord
  - Test in VS Code

### 🐛 Error Handling

- [ ] **AI Model Not Available**
  - App works without AI (basic clipboard manager)
  - Appropriate error messages shown

- [ ] **Tesseract Not Installed**
  - OCR feature shows error message
  - App continues to work otherwise

- [ ] **Clipboard Locked**
  - App handles locked clipboard gracefully
  - No crashes when clipboard unavailable

- [ ] **Database Errors**
  - App handles database corruption
  - Can recreate database if needed

### ⚡ Performance Testing

- [ ] **Large Clipboard History**
  - Test with 100+ items
  - UI remains responsive
  - Refresh is fast (< 1 second)

- [ ] **Long Text Content**
  - Copy very long text (10,000+ chars)
  - App handles without slowdown
  - Database saves correctly

- [ ] **AI Response Time**
  - First query: 5-15 seconds (model load)
  - Subsequent queries: 1-3 seconds
  - UI doesn't freeze during generation

## Common Issues

### Issue: Hotkeys Not Working
**Solution:** Run application as Administrator or check if another app is blocking global hotkeys

### Issue: AI Model Fails to Load
**Solution:** 
- Check internet connection (first download)
- Ensure sufficient RAM (2GB+ free)
- Try a smaller model by editing `ai_service.py`

### Issue: OCR Not Working
**Solution:**
- Install Tesseract OCR
- Add Tesseract to system PATH
- Verify installation: `tesseract --version`

### Issue: Clipboard Monitoring Stops
**Solution:**
- Check if monitoring is enabled in UI
- Restart application
- Check Windows permissions

### Issue: Database Errors
**Solution:**
- Delete `%APPDATA%\Clipit\clipit.db`
- Restart application (will recreate database)

## Windows-Specific Testing

- [ ] Test on Windows 10
- [ ] Test on Windows 11
- [ ] Test with High DPI displays
- [ ] Test with multiple monitors
- [ ] Test with UAC enabled
- [ ] Test after Windows Updates

## Security Testing

- [ ] Sensitive data (passwords) is stored in plain text - WARN USER
- [ ] Clear history removes all data
- [ ] Database file permissions are correct
- [ ] No data sent to external servers (except for initial model download)

## Report Template

```
# Test Report - Clipit

**Date:** YYYY-MM-DD
**Tester:** Your Name
**Windows Version:** Windows 10/11 Build XXXXX
**Python Version:** X.X.X

## Passed Tests
- ✅ Test name

## Failed Tests
- ❌ Test name
  - Error: Description
  - Steps to reproduce:
    1. Step 1
    2. Step 2
  - Expected: What should happen
  - Actual: What actually happened

## Notes
- Any additional observations

## Overall Status
🟢 Ready for Release / 🟡 Minor Issues / 🔴 Major Issues
```

## Automated Testing (Future)

Create unit tests:
```bash
pytest tests/
```

Run type checking:
```bash
mypy clipit/
```

Check code quality:
```bash
pylint clipit/
```

