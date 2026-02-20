# 🚀 PUSH TO GITHUB - STEP BY STEP GUIDE

Your Underground Toronto Navigator app is ready to be published on GitHub!

---

## ⚡ QUICK METHOD - GitHub Desktop (EASIEST!)

### 1. Install GitHub Desktop
- Download: https://desktop.github.com/
- Install and sign in with your GitHub account

### 2. Add This Repository
- Open GitHub Desktop
- File → Add Local Repository
- Choose: `C:\Users\whdgu\OneDrive\Desktop\UNDERGROUND`
- Click "Add Repository"

### 3. Publish to GitHub
- Click "Publish repository" button
- Repository name: `underground-toronto`
- Description: `Navigate Toronto's underground PATH system with GPS and sensor technology`
- Choose: ☑ Public (recommended) or ☐ Private
- **UNCHECK** "Keep this code private" if you want it public
- Click "Publish repository"

**DONE! Your app is now on GitHub! 🎉**

---

## 💻 COMMAND LINE METHOD

### Step 1: Configure Git (First Time Only)
```powershell
# Set your GitHub username
git config --global user.name "YourGitHubUsername"

# Set your GitHub email
git config --global user.email "your.email@example.com"
```

### Step 2: Initialize and Commit
```powershell
# Make sure you're in the project directory
cd "C:\Users\whdgu\OneDrive\Desktop\UNDERGROUND"

# Initialize git (if not already done)
git init

# Add all files
git add .

# Commit with message
git commit -m "Initial commit: Complete Underground Toronto Navigator with store deployment"
```

### Step 3: Create GitHub Repository
1. Go to: https://github.com/new
2. Repository name: `underground-toronto`
3. Description: `Navigate Toronto's underground PATH system with GPS and sensor technology`
4. Select: **Public** (for portfolio) or **Private**
5. **DON'T** initialize with README, .gitignore, or license (we already have them!)
6. Click "Create repository"

### Step 4: Add Remote and Push
```powershell
# Replace 'yourusername' with your actual GitHub username
git remote add origin https://github.com/yourusername/underground-toronto.git

# Set main branch
git branch -M main

# Push to GitHub
git push -u origin main
```

**If you get an authentication error, see "Authentication Methods" below.**

---

## 🔐 AUTHENTICATION METHODS

### Option 1: Personal Access Token (Recommended)

**Create Token:**
1. Go to: https://github.com/settings/tokens
2. Click "Generate new token" → "Generate new token (classic)"
3. Note: "Underground Toronto App"
4. Expiration: 90 days (or longer)
5. Select scopes: ☑ repo (Full control of private repositories)
6. Click "Generate token"
7. **COPY THE TOKEN** (you won't see it again!)

**Use Token:**
```powershell
git push -u origin main

# When prompted:
# Username: your-github-username
# Password: paste-your-token-here
```

**Save Token (Optional):**
```powershell
# Windows Credential Manager will remember it
git config --global credential.helper wincred
```

### Option 2: SSH Key

**Generate SSH Key:**
```powershell
ssh-keygen -t ed25519 -C "your.email@example.com"
# Press Enter 3 times (default location, no passphrase)
```

**Add to GitHub:**
1. Copy your public key:
```powershell
Get-Content ~/.ssh/id_ed25519.pub | Set-Clipboard
```
2. Go to: https://github.com/settings/keys
3. Click "New SSH key"
4. Title: "Windows PC"
5. Paste the key
6. Click "Add SSH key"

**Use SSH Remote:**
```powershell
# Change remote URL to SSH
git remote set-url origin git@github.com:yourusername/underground-toronto.git

# Push
git push -u origin main
```

---

## ✅ AFTER PUSHING

### Verify Upload
1. Visit: `https://github.com/yourusername/underground-toronto`
2. Check that all files are there
3. Look for: lib/, android/, ios/, README.md, etc.

### Add Repository Info
1. Click "Add description" → Enter description
2. Click ⚙️ (Settings) → Under "About"
3. Add topics: `flutter`, `dart`, `gps`, `navigation`, `toronto`, `mobile-app`
4. Add website (if you have one)

### Enable GitHub Pages (For Privacy Policy)
1. Go to repository Settings
2. Scroll to "Pages" section
3. Source: **Deploy from a branch**
4. Branch: **main**, folder: **/ (root)**
5. Click Save

**Your privacy policy will be at:**
`https://yourusername.github.io/underground-toronto/PRIVACY_POLICY`

Use this URL in your app store listings!

### Add README Badge (Optional)
Add this at the top of README.md:
```markdown
![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)
```

---

## 🎯 NEXT STEPS

### 1. Clone on Another Computer (Optional)
```bash
git clone https://github.com/yourusername/underground-toronto.git
cd underground-toronto
flutter pub get
flutter run
```

### 2. Make Changes and Update
```powershell
# After making changes
git add .
git commit -m "Description of changes"
git push
```

### 3. Deploy to App Stores
Now that your code is on GitHub:
- Follow `DEPLOY_NOW.md` to deploy to stores
- Your privacy policy URL is ready!
- Portfolio link ready to share!

---

## 🆘 TROUBLESHOOTING

### "git: command not found"
**Install Git:**
- Download: https://git-scm.com/download/win
- Run installer with default settings
- Restart PowerShell/Terminal

### "Permission denied (publickey)"
**Fix SSH:**
1. Make sure SSH key is added to GitHub
2. Test connection: `ssh -T git@github.com`
3. Should see: "Hi username! You've successfully authenticated"

### "fatal: remote origin already exists"
**Remove and re-add:**
```powershell
git remote remove origin
git remote add origin https://github.com/yourusername/underground-toronto.git
```

### "Updates were rejected"
**Pull first:**
```powershell
git pull origin main --allow-unrelated-histories
git push -u origin main
```

### Authentication Keeps Failing
**Use GitHub Desktop - it's easier!**
- Download from https://desktop.github.com/
- Much simpler authentication
- Visual interface for all operations

---

## 📱 USING GITHUB DESKTOP (DETAILED)

### Initial Setup
1. Download and install GitHub Desktop
2. Sign in: File → Options → Accounts → Sign in
3. Enter GitHub username and password
4. Authorize GitHub Desktop

### Add Repository
1. File → Add local repository
2. Choose folder: `C:\Users\whdgu\OneDrive\Desktop\UNDERGROUND`
3. Click "Add repository"

If it says "not a git repository":
1. Click "create a repository instead"
2. Skip initialization
3. It will detect existing project

### Commit Changes
1. Review changes in left panel
2. All files should be shown
3. Summary: "Initial commit: Underground Toronto Navigator"
4. Description: "Complete app with GPS, accelerometer, and store deployment"
5. Click "Commit to main"

### Publish to GitHub
1. Click "Publish repository" in top bar
2. Name: `underground-toronto`
3. Description: `Navigate Toronto's underground PATH system`
4. Organization: (Leave as is / your username)
5. Keep code private: **UNCHECK** for public
6. Click "Publish repository"

### Done!
- Your repository is now on GitHub
- Visit it at: https://github.com/yourusername/underground-toronto

### Future Updates
1. Make changes to your code
2. Open GitHub Desktop
3. It will show changed files
4. Enter commit message
5. Click "Commit to main"
6. Click "Push origin" to upload

---

## 🎉 SUCCESS!

Once your code is on GitHub:

✅ **Portfolio Ready** - Share link with recruiters/employers
✅ **Privacy Policy Hosted** - Use GitHub Pages URL for stores
✅ **Backup** - Your code is safely backed up
✅ **Collaboration** - Others can contribute
✅ **Version Control** - Track all changes
✅ **Professional** - Shows you know git/GitHub

**Repository URL Pattern:**
`https://github.com/yourusername/underground-toronto`

**Use this in:**
- Resume/CV
- LinkedIn
- Job applications
- App store "website" field
- Developer portfolio

---

## 💡 QUICK REFERENCE

```powershell
# Common Git Commands
git status                 # Check what changed
git add .                  # Stage all changes
git commit -m "message"    # Commit with message
git push                   # Push to GitHub
git pull                   # Pull from GitHub
git log --oneline          # View commit history
git remote -v              # View remote URLs

# GitHub URLs
https://github.com/yourusername/underground-toronto           # Your repo
https://github.com/yourusername/underground-toronto/issues    # Issues
https://github.com/yourusername/underground-toronto/settings  # Settings
```

---

## 🚀 READY TO PUSH?

**Easiest way:**
1. Download GitHub Desktop: https://desktop.github.com/
2. Run the push-to-github.ps1 script: `.\scripts\push-to-github.ps1`
3. Follow the prompts

**Or follow the step-by-step instructions above!**

---

**Need help? Check:**
- GitHub Docs: https://docs.github.com/
- Git Docs: https://git-scm.com/doc
- GitHub Desktop Help: https://docs.github.com/en/desktop

**Your app is amazing - share it with the world! 🌍**
