@echo off
REM Clipit Launcher for Windows

echo.
echo ========================================
echo    Clipit - Smart Clipboard Manager
echo ========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo.
    echo Please install Python from: https://www.python.org/downloads/
    echo Make sure to check "Add Python to PATH" during installation
    echo.
    pause
    exit /b 1
)

echo [1/3] Python found: 
python --version
echo.

REM Check if dependencies are installed
echo [2/3] Checking dependencies...
python -c "import PyQt5" >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: Dependencies not installed
    echo.
    echo Please run: pip install -r requirements.txt
    echo.
    pause
    exit /b 1
)
echo Dependencies OK
echo.

REM Run the application
echo [3/3] Starting Clipit...
echo.
echo Press Ctrl+C to stop the application
echo.
python -m clipit.main

if errorlevel 1 (
    echo.
    echo ERROR: Application failed to start
    echo Check the error messages above
    echo.
    pause
)

