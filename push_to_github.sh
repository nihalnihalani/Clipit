#!/bin/bash
# Helper script to push Clipit to GitHub

echo "=========================================="
echo "  Push Clipit to GitHub"
echo "=========================================="
echo ""

# Check if GitHub username is provided
if [ -z "$1" ]; then
    echo "Usage: ./push_to_github.sh YOUR_GITHUB_USERNAME"
    echo ""
    echo "Example: ./push_to_github.sh nihalnihalani"
    echo ""
    echo "Or manually:"
    echo "  1. Create repo at: https://github.com/new"
    echo "  2. Run these commands:"
    echo "     git remote add origin https://github.com/YOUR_USERNAME/clipit.git"
    echo "     git push -u origin main"
    exit 1
fi

GITHUB_USERNAME="$1"
REPO_URL="https://github.com/$GITHUB_USERNAME/clipit.git"

echo "GitHub Username: $GITHUB_USERNAME"
echo "Repository URL: $REPO_URL"
echo ""
echo "⚠️  IMPORTANT: Make sure you've created the repository on GitHub first!"
echo "   Go to: https://github.com/new"
echo "   Name: clipit"
echo "   DO NOT initialize with README"
echo ""
read -p "Have you created the repository? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Please create the repository first, then run this script again."
    exit 1
fi

echo ""
echo "Step 1: Adding remote..."
git remote add origin "$REPO_URL" 2>/dev/null || git remote set-url origin "$REPO_URL"

echo "Step 2: Pushing to GitHub..."
git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✅ Successfully pushed to GitHub!"
    echo "=========================================="
    echo ""
    echo "Your repository: https://github.com/$GITHUB_USERNAME/clipit"
    echo ""
else
    echo ""
    echo "=========================================="
    echo "❌ Push failed!"
    echo "=========================================="
    echo ""
    echo "Common issues:"
    echo "  1. Repository doesn't exist - create it first"
    echo "  2. Authentication failed - check your credentials"
    echo "  3. Permission denied - make sure you own the repository"
    echo ""
    echo "Try manually:"
    echo "  git remote add origin $REPO_URL"
    echo "  git push -u origin main"
    echo ""
fi

