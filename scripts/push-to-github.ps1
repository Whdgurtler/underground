# GitHub Push Script for Underground Toronto Navigator
# Run this script to push your app to GitHub

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   UNDERGROUND TORONTO - PUSH TO GITHUB                     ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Step 1: Configure Git (if not already configured)
Write-Host "Step 1: Configuring Git..." -ForegroundColor Yellow
$userName = git config user.name
$userEmail = git config user.email

if ([string]::IsNullOrEmpty($userName)) {
    $userName = Read-Host "Enter your GitHub username"
    git config --global user.name "$userName"
    Write-Host "✓ Git username configured: $userName" -ForegroundColor Green
} else {
    Write-Host "✓ Git username already configured: $userName" -ForegroundColor Green
}

if ([string]::IsNullOrEmpty($userEmail)) {
    $userEmail = Read-Host "Enter your GitHub email"
    git config --global user.email "$userEmail"
    Write-Host "✓ Git email configured: $userEmail" -ForegroundColor Green
} else {
    Write-Host "✓ Git email already configured: $userEmail" -ForegroundColor Green
}

Write-Host ""

# Step 2: Initialize Git Repository (if needed)
Write-Host "Step 2: Checking Git repository..." -ForegroundColor Yellow
if (-not (Test-Path ".git")) {
    git init
    Write-Host "✓ Git repository initialized" -ForegroundColor Green
} else {
    Write-Host "✓ Git repository already exists" -ForegroundColor Green
}

Write-Host ""

# Step 3: Add all files
Write-Host "Step 3: Adding files to Git..." -ForegroundColor Yellow
git add .
Write-Host "✓ All files staged for commit" -ForegroundColor Green

Write-Host ""

# Step 4: Commit
Write-Host "Step 4: Committing files..." -ForegroundColor Yellow
$commitMessage = "Initial commit: Complete Underground Toronto Navigator with store deployment"
git commit -m "$commitMessage"
Write-Host "✓ Files committed" -ForegroundColor Green

Write-Host ""

# Step 5: Create GitHub Repository
Write-Host "Step 5: Setting up GitHub remote..." -ForegroundColor Yellow
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "   CREATE YOUR GITHUB REPOSITORY NOW" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Go to: https://github.com/new" -ForegroundColor White
Write-Host ""
Write-Host "2. Repository name: underground-toronto" -ForegroundColor White
Write-Host "   Description: Navigate Toronto's underground PATH with GPS & sensors" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Select: ○ Public  (recommended for portfolio)" -ForegroundColor White
Write-Host "          or ○ Private (if you prefer)" -ForegroundColor Gray
Write-Host ""
Write-Host "4. DON'T add README, .gitignore, or license (we have them!)" -ForegroundColor White
Write-Host ""
Write-Host "5. Click 'Create repository'" -ForegroundColor White
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

$repoUrl = Read-Host "Enter your GitHub repository URL (e.g., https://github.com/yourusername/underground-toronto.git)"

if ([string]::IsNullOrEmpty($repoUrl)) {
    Write-Host ""
    Write-Host "No URL provided. You can add the remote later with:" -ForegroundColor Yellow
    Write-Host "  git remote add origin https://github.com/yourusername/underground-toronto.git" -ForegroundColor Gray
    Write-Host ""
    pause
    exit
}

# Add remote
git remote remove origin 2>$null  # Remove if exists
git remote add origin $repoUrl
Write-Host "✓ Remote repository added" -ForegroundColor Green

Write-Host ""

# Step 6: Push to GitHub
Write-Host "Step 6: Pushing to GitHub..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Pushing main branch..." -ForegroundColor Gray

# Try to push
try {
    git branch -M main
    git push -u origin main
    
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host "   ✓ SUCCESS! YOUR APP IS NOW ON GITHUB! 🎉" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your repository: $repoUrl" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Visit your GitHub repo and verify files uploaded" -ForegroundColor White
    Write-Host "  2. Add repository description and topics (flutter, dart, gps, navigation)" -ForegroundColor White
    Write-Host "  3. Enable GitHub Pages for PRIVACY_POLICY.md:" -ForegroundColor White
    Write-Host "     Settings → Pages → Source: main branch → Save" -ForegroundColor Gray
    Write-Host "  4. Your privacy policy will be at:" -ForegroundColor White
    Write-Host "     https://yourusername.github.io/underground-toronto/PRIVACY_POLICY" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Ready to deploy to stores?" -ForegroundColor Yellow
    Write-Host "  Follow: DEPLOY_NOW.md" -ForegroundColor White
    Write-Host ""
    
} catch {
    Write-Host ""
    Write-Host "⚠️  Authentication required!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "If you see an authentication error, you need to:" -ForegroundColor White
    Write-Host ""
    Write-Host "Option 1 - GitHub Desktop (Easiest):" -ForegroundColor Cyan
    Write-Host "  1. Download: https://desktop.github.com/" -ForegroundColor Gray
    Write-Host "  2. Sign in with your GitHub account" -ForegroundColor Gray
    Write-Host "  3. Add this local repository" -ForegroundColor Gray
    Write-Host "  4. Click 'Publish repository'" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Option 2 - Personal Access Token:" -ForegroundColor Cyan
    Write-Host "  1. Go to: https://github.com/settings/tokens" -ForegroundColor Gray
    Write-Host "  2. Generate new token (classic)" -ForegroundColor Gray
    Write-Host "  3. Select: repo (full control)" -ForegroundColor Gray
    Write-Host "  4. Copy token" -ForegroundColor Gray
    Write-Host "  5. Use token as password when pushing" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Option 3 - SSH Key:" -ForegroundColor Cyan
    Write-Host "  1. Generate SSH key: ssh-keygen -t ed25519 -C 'your@email.com'" -ForegroundColor Gray
    Write-Host "  2. Add to GitHub: https://github.com/settings/keys" -ForegroundColor Gray
    Write-Host "  3. Change remote to SSH:" -ForegroundColor Gray
    Write-Host "     git remote set-url origin git@github.com:username/underground-toronto.git" -ForegroundColor Gray
    Write-Host "  4. Push: git push -u origin main" -ForegroundColor Gray
    Write-Host ""
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "           GITHUB PUSH COMPLETE!" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

pause
