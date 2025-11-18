#!/bin/bash
# One-click push to GitHub for Clipit

echo "=========================================="
echo "  Pushing Clipit to GitHub..."
echo "=========================================="
echo ""
echo "Repository: https://github.com/nihalnihalani/clipit"
echo ""

# Check if repo exists on GitHub first
echo "⚠️  IMPORTANT: Make sure you created the repository first!"
echo "   Go to: https://github.com/new"
echo "   Name: clipit"
echo "   Visibility: Public"
echo "   DO NOT initialize with README"
echo ""
echo "Press Enter when ready to push..."
read

echo ""
echo "Pushing to GitHub..."
echo ""

git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✅ SUCCESS! Repository is live!"
    echo "=========================================="
    echo ""
    echo "🎉 Your Clipit repository is now on GitHub!"
    echo ""
    echo "View it at: https://github.com/nihalnihalani/clipit"
    echo ""
    echo "Next steps:"
    echo "  1. Visit your repository"
    echo "  2. Add topics: python, clipboard-manager, ai, windows"
    echo "  3. Consider pinning it to your profile"
    echo ""
else
    echo ""
    echo "=========================================="
    echo "❌ Push failed"
    echo "=========================================="
    echo ""
    echo "Common solutions:"
    echo ""
    echo "1. Create the repository first:"
    echo "   https://github.com/new"
    echo ""
    echo "2. Use Personal Access Token as password:"
    echo "   - Go to: https://github.com/settings/tokens"
    echo "   - Generate new token (classic)"
    echo "   - Select: repo (full control)"
    echo "   - Copy and use as password"
    echo ""
    echo "3. Or try SSH:"
    echo "   git remote set-url origin git@github.com:nihalnihalani/clipit.git"
    echo "   git push -u origin main"
    echo ""
fi

