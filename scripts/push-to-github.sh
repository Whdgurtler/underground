#!/bin/bash

# GitHub Push Script for Underground Toronto Navigator
# Run this script to push your app to GitHub

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║   UNDERGROUND TORONTO - PUSH TO GITHUB                     ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Step 1: Configure Git
echo -e "${YELLOW}Step 1: Configuring Git...${NC}"
userName=$(git config user.name)
userEmail=$(git config user.email)

if [ -z "$userName" ]; then
    read -p "Enter your GitHub username: " userName
    git config --global user.name "$userName"
    echo -e "${GREEN}✓ Git username configured: $userName${NC}"
else
    echo -e "${GREEN}✓ Git username already configured: $userName${NC}"
fi

if [ -z "$userEmail" ]; then
    read -p "Enter your GitHub email: " userEmail
    git config --global user.email "$userEmail"
    echo -e "${GREEN}✓ Git email configured: $userEmail${NC}"
else
    echo -e "${GREEN}✓ Git email already configured: $userEmail${NC}"
fi

echo ""

# Step 2: Initialize Git Repository
echo -e "${YELLOW}Step 2: Checking Git repository...${NC}"
if [ ! -d ".git" ]; then
    git init
    echo -e "${GREEN}✓ Git repository initialized${NC}"
else
    echo -e "${GREEN}✓ Git repository already exists${NC}"
fi

echo ""

# Step 3: Add files
echo -e "${YELLOW}Step 3: Adding files to Git...${NC}"
git add .
echo -e "${GREEN}✓ All files staged for commit${NC}"

echo ""

# Step 4: Commit
echo -e "${YELLOW}Step 4: Committing files...${NC}"
git commit -m "Initial commit: Complete Underground Toronto Navigator with store deployment"
echo -e "${GREEN}✓ Files committed${NC}"

echo ""

# Step 5: Create GitHub Repository
echo -e "${YELLOW}Step 5: Setting up GitHub remote...${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${YELLOW}   CREATE YOUR GITHUB REPOSITORY NOW${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Go to: https://github.com/new"
echo ""
echo "2. Repository name: underground-toronto"
echo "   Description: Navigate Toronto's underground PATH with GPS & sensors"
echo ""
echo "3. Select: ○ Public (recommended for portfolio)"
echo "          or ○ Private (if you prefer)"
echo ""
echo "4. DON'T add README, .gitignore, or license (we have them!)"
echo ""
echo "5. Click 'Create repository'"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -p "Enter your GitHub repository URL (e.g., https://github.com/yourusername/underground-toronto.git): " repoUrl

if [ -z "$repoUrl" ]; then
    echo ""
    echo -e "${YELLOW}No URL provided. You can add the remote later with:${NC}"
    echo "  git remote add origin https://github.com/yourusername/underground-toronto.git"
    echo ""
    exit 0
fi

# Add remote
git remote remove origin 2>/dev/null
git remote add origin "$repoUrl"
echo -e "${GREEN}✓ Remote repository added${NC}"

echo ""

# Step 6: Push to GitHub
echo -e "${YELLOW}Step 6: Pushing to GitHub...${NC}"
echo ""

git branch -M main
if git push -u origin main; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${GREEN}   ✓ SUCCESS! YOUR APP IS NOW ON GITHUB! 🎉${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo -e "${CYAN}Your repository: $repoUrl${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "  1. Visit your GitHub repo and verify files uploaded"
    echo "  2. Add repository description and topics (flutter, dart, gps, navigation)"
    echo "  3. Enable GitHub Pages for PRIVACY_POLICY.md:"
    echo "     Settings → Pages → Source: main branch → Save"
    echo "  4. Your privacy policy will be at:"
    echo "     https://yourusername.github.io/underground-toronto/PRIVACY_POLICY"
    echo ""
    echo -e "${YELLOW}Ready to deploy to stores?${NC}"
    echo "  Follow: DEPLOY_NOW.md"
    echo ""
else
    echo ""
    echo -e "${YELLOW}⚠️  Authentication required!${NC}"
    echo ""
    echo "If you see an authentication error, you need to:"
    echo ""
    echo -e "${CYAN}Option 1 - Personal Access Token:${NC}"
    echo "  1. Go to: https://github.com/settings/tokens"
    echo "  2. Generate new token (classic)"
    echo "  3. Select: repo (full control)"
    echo "  4. Copy token"
    echo "  5. Use token as password when pushing"
    echo ""
    echo -e "${CYAN}Option 2 - SSH Key:${NC}"
    echo "  1. Generate SSH key: ssh-keygen -t ed25519 -C 'your@email.com'"
    echo "  2. Add to GitHub: https://github.com/settings/keys"
    echo "  3. Change remote to SSH:"
    echo "     git remote set-url origin git@github.com:username/underground-toronto.git"
    echo "  4. Push: git push -u origin main"
    echo ""
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "           GITHUB PUSH COMPLETE!"
echo "═══════════════════════════════════════════════════════════"
echo ""
