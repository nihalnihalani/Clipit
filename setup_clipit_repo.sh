#!/bin/bash
# Setup script to create a new Clipit repository ready for GitHub

echo "=========================================="
echo "  Clipit Repository Setup for GitHub"
echo "=========================================="
echo ""

# Create a new directory for the standalone Clipit repo
CLIPIT_REPO_DIR="$HOME/Desktop/clipit-repo"

echo "Step 1: Creating standalone repository directory..."
mkdir -p "$CLIPIT_REPO_DIR"

echo "Step 2: Copying Clipit files..."
cp -r clipit/* "$CLIPIT_REPO_DIR/"
cp clipit/.* "$CLIPIT_REPO_DIR/" 2>/dev/null || true
cp README.md "$CLIPIT_REPO_DIR/"
cp INSTALL.md "$CLIPIT_REPO_DIR/"
cp TESTING.md "$CLIPIT_REPO_DIR/"
cp TROUBLESHOOTING.md "$CLIPIT_REPO_DIR/"
cp MIGRATION_SUMMARY.md "$CLIPIT_REPO_DIR/"
cp STATUS.md "$CLIPIT_REPO_DIR/"
cp requirements.txt "$CLIPIT_REPO_DIR/"
cp run.bat "$CLIPIT_REPO_DIR/"
cp test_clipit.py "$CLIPIT_REPO_DIR/"

echo "Step 3: Initializing git repository..."
cd "$CLIPIT_REPO_DIR"
git init

echo "Step 4: Creating .gitignore..."
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Virtual Environment
venv/
ENV/
env/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Application
*.db
*.sqlite
*.sqlite3
images/
logs/
*.log

# Hugging Face models cache
.cache/
models/
EOF

echo "Step 5: Adding all files..."
git add .

echo "Step 6: Creating initial commit..."
git commit -m "Initial commit: Clipit - Smart Clipboard Manager for Windows

Complete Windows application with AI-powered clipboard management

Features:
- Automatic clipboard monitoring (text and images)
- AI-powered question answering using LFM2-350M/Llama-3.2-1B
- Smart text capture and intelligent replacement
- OCR screen text extraction with Tesseract
- Floating dog animation for visual feedback
- Global hotkeys (Alt+X, Alt+V, Alt+S)
- SQLite database with persistent storage
- System tray integration

Tech Stack:
- Python 3.8+ with PyQt5
- SQLAlchemy for database
- Transformers for AI model
- Tesseract for OCR
- pynput for global hotkeys

Documentation:
- Complete installation guide
- Comprehensive testing checklist
- Troubleshooting guide
- Migration documentation from macOS version

Status: Ready for Windows 10/11 testing

Statistics:
- 16 Python files
- 1,771 lines of code
- Complete documentation
- All features implemented"

echo ""
echo "=========================================="
echo "✅ Repository prepared successfully!"
echo "=========================================="
echo ""
echo "Repository location: $CLIPIT_REPO_DIR"
echo ""
echo "Next steps:"
echo ""
echo "1. Create repository on GitHub:"
echo "   Go to: https://github.com/new"
echo "   Name: clipit"
echo "   Description: Smart Clipboard Manager for Windows with AI"
echo "   Visibility: Public or Private (your choice)"
echo "   DO NOT initialize with README"
echo ""
echo "2. Push to GitHub:"
echo "   cd $CLIPIT_REPO_DIR"
echo "   git remote add origin https://github.com/YOUR_USERNAME/clipit.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "Or if you have GitHub CLI installed:"
echo "   cd $CLIPIT_REPO_DIR"
echo "   gh repo create clipit --public --source=. --remote=origin --push"
echo ""
echo "=========================================="

