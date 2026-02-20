# Deployment Guide - Underground Toronto Navigator

## 🚀 Complete Store Deployment Guide

This guide covers everything needed to deploy to Google Play Store and Apple App Store.

---

## Part 1: Google Play Store Deployment

### Step 1: Create Signing Key

```bash
# Navigate to android/app
cd android/app

# Generate upload keystore (do this once)
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Answer the prompts:
# - Enter keystore password (SAVE THIS!)
# - Re-enter password
# - Enter your name, organization, city, state, country
# - Enter key password (can be same as keystore password)
```

**IMPORTANT:** Save these credentials securely! You'll need them for every release.

### Step 2: Configure Key Properties

Create `android/key.properties`:
```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

⚠️ **NEVER commit key.properties to Git!** (Already in .gitignore)

### Step 3: Build Release APK/Bundle

```bash
# Build App Bundle (recommended for Play Store)
flutter build appbundle --release

# Or build APK
flutter build apk --release --split-per-abi

# Output locations:
# Bundle: build/app/outputs/bundle/release/app-release.aab
# APK: build/app/outputs/flutter-apk/app-release.apk
```

### Step 4: Create Play Store Listing

1. Go to [Google Play Console](https://play.google.com/console)
2. Create a new app
3. Fill in required information:
   - **App name:** Underground Toronto Navigator
   - **Category:** Maps & Navigation
   - **Content rating:** Complete questionnaire (should be "Everyone")
   - **Target audience:** 13+

### Step 5: Upload Build

1. Go to "Production" → "Create new release"
2. Upload the .aab file
3. Fill in release notes
4. Submit for review

### Store Listing Assets Needed:

- **App icon:** 512x512 PNG
- **Feature graphic:** 1024x500 PNG
- **Screenshots:** At least 2 (phone: 16:9 or 9:16)
  - 1080x1920 or 1920x1080 recommended
- **Short description:** Max 80 characters
- **Full description:** Max 4000 characters
- **Privacy policy URL:** Required

---

## Part 2: Apple App Store Deployment

### Step 1: Configure Xcode Project

```bash
# Open Xcode
open ios/Runner.xcworkspace

# In Xcode:
# 1. Select Runner in project navigator
# 2. Go to "Signing & Capabilities"
# 3. Select your team (requires Apple Developer Account - $99/year)
# 4. Xcode will automatically manage signing
```

### Step 2: Set Bundle Identifier

In Xcode, set unique bundle ID:
- Example: `com.yourname.undergroundtoronto`
- Must be unique across all App Store apps

### Step 3: Configure Info.plist

Already configured with required permissions:
- Location permissions ✅
- Motion sensor permissions ✅
- Google Maps integration ✅

### Step 4: Build for App Store

```bash
# Create iOS release build
flutter build ipa --release

# Output location: build/ios/ipa/underground_toronto.ipa
```

### Step 5: Upload to App Store Connect

**Option 1: Using Xcode**
```bash
open ios/Runner.xcworkspace

# In Xcode:
# 1. Select "Any iOS Device" as destination
# 2. Product → Archive
# 3. Wait for archive to complete
# 4. Click "Distribute App"
# 5. Choose "App Store Connect"
# 6. Follow the wizard
```

**Option 2: Using Transporter App**
1. Download [Transporter](https://apps.apple.com/app/transporter/id1450874784)
2. Open the .ipa file in Transporter
3. Click "Deliver"

### Step 6: Create App Store Listing

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Create new app
3. Fill in required information:
   - **App name:** Underground Toronto Navigator
   - **Category:** Navigation
   - **Content rights:** You own or have rights
   - **Age rating:** 4+

### App Store Assets Needed:

- **App icon:** 1024x1024 PNG (no alpha)
- **Screenshots:**
  - iPhone 6.7": 1290x2796 (3 required)
  - iPhone 6.5": 1242x2688 (3 required)
  - iPad Pro 12.9": 2048x2732 (optional)
- **App preview videos:** Optional but recommended
- **Description:** No length limit
- **Keywords:** Max 100 characters
- **Support URL:** Required
- **Privacy policy URL:** Required

---

## Part 3: Pre-Launch Checklist

### ✅ Code Readiness
- [ ] All features tested on real device
- [ ] GPS tracking works outdoors
- [ ] Accelerometer mode works indoors
- [ ] Permissions properly requested
- [ ] No crashes or major bugs
- [ ] Google Maps API key is valid
- [ ] Error handling in place

### ✅ Legal & Privacy
- [ ] Privacy policy created and hosted
- [ ] Terms of service (if applicable)
- [ ] Permissions explained to users
- [ ] Data collection disclosed
- [ ] GDPR compliance (if serving EU)
- [ ] Age restrictions appropriate

### ✅ App Store Assets
- [ ] App icons created (all sizes)
- [ ] Screenshots taken (multiple devices)
- [ ] Feature graphics created
- [ ] Description written
- [ ] Keywords researched
- [ ] Support email/website ready

### ✅ Accounts & Subscriptions
- [ ] Google Play Developer account ($25 one-time)
- [ ] Apple Developer Program ($99/year)
- [ ] Google Cloud account (for Maps API)
- [ ] Domain for privacy policy (optional)

---

## Part 4: Post-Launch

### Monitoring
- Check crash reports daily
- Review user feedback
- Monitor GPS/sensor performance metrics
- Track downloads and user engagement

### Updates
```bash
# Increment version in pubspec.yaml
version: 1.0.1+2  # 1.0.1 = version name, 2 = build number

# Build new release
flutter build appbundle --release  # Android
flutter build ipa --release        # iOS

# Upload to stores
```

### Marketing
- Share on social media
- Submit to app review sites
- Create landing page
- Engage with Toronto tech community
- Target PATH users specifically

---

## Part 5: Common Issues & Solutions

### Android Issues

**Issue:** "App not optimized"
- **Solution:** Upload App Bundle (.aab), not APK

**Issue:** "Missing privacy policy"
- **Solution:** Add URL in Play Console settings

**Issue:** "Permissions not explained"
- **Solution:** Ensure manifest has proper permission descriptions

### iOS Issues

**Issue:** "Missing compliance information"
- **Solution:** Declare encryption usage (select "No" if using standard HTTPS only)

**Issue:** "Invalid bundle ID"
- **Solution:** Must be unique and match what's in Xcode

**Issue:** "Missing required device capabilities"
- **Solution:** Ensure Info.plist has all required permissions

---

## Part 6: Store Listing Copy

### Short Description (80 chars max)
```
Navigate Toronto's underground PATH system with GPS and sensor technology
```

### Full Description Template

```
🗺️ Underground Toronto Navigator

Never get lost in Toronto's PATH system again! This innovative app combines GPS and accelerometer technology to track your position even when underground.

✨ KEY FEATURES

📍 GPS Tracking
• Real-time location tracking above ground
• High-accuracy positioning
• Automatic satellite lock

🎯 Underground Navigation
• Accelerometer-based dead reckoning
• Continues tracking when GPS unavailable
• Gyroscope heading detection

🔄 Automatic Mode Switching
• Detects underground transitions automatically
• Seamless switching between GPS and sensors
• No manual intervention needed

🗺️ Interactive Map
• Live position updates
• Complete path visualization
• Blue = GPS, Orange = Estimated

📊 Real-Time Information
• Current coordinates
• Altitude tracking
• Heading direction
• GPS accuracy
• Distance traveled

⚙️ Smart Features
• Sensor calibration
• Path history
• Position markers
• Toronto PATH detection

🎯 WHO IS THIS FOR?

• Toronto commuters using PATH
• Visitors exploring downtown Toronto
• Anyone navigating underground spaces
• Emergency responders
• Urban explorers

🔒 PRIVACY

• Location used only for navigation
• No data sent to servers
• All processing on-device
• No tracking or analytics

📱 REQUIREMENTS

• GPS capability
• Accelerometer sensor
• Gyroscope sensor
• Internet for map tiles

🌟 HOW IT WORKS

When above ground, the app uses GPS satellites for accurate positioning. When you go underground (detected automatically), it switches to using your phone's motion sensors to estimate your position through dead reckoning.

Perfect for navigating Toronto's famous PATH underground walkway system!

📧 SUPPORT

Questions or issues? Contact us at: support@undergroundtoronto.app

🌐 LEARN MORE

Visit our website for tips, FAQs, and video tutorials.

---

Made with ❤️ for Toronto
```

### Keywords (100 chars max)
```
toronto,path,underground,navigation,gps,map,indoor,subway,tunnel,downtown,sensor,tracking,walk
```

---

## Part 7: Estimated Timeline

| Task | Time | Notes |
|------|------|-------|
| Create signing keys | 10 min | One-time setup |
| Configure build files | 15 min | Already done! |
| Create app icons | 1-2 hours | Use design tool |
| Take screenshots | 30 min | Test on real devices |
| Write store listings | 1 hour | Use templates above |
| Set up accounts | 30 min | If not already done |
| Build releases | 10 min | Automated process |
| Upload to stores | 20 min | Per platform |
| Google review | 1-3 days | Usually same day |
| Apple review | 1-7 days | Average 2-3 days |

**Total time to launch:** ~5-10 hours of work + review time

---

## Part 8: Cost Breakdown

### One-Time Costs
- Google Play Developer: **$25** (lifetime)
- App icons/graphics (DIY): **$0**
- Optional: Professional icon design: **$50-200**

### Annual Costs
- Apple Developer Program: **$99/year**
- Google Maps API: **$0-50/month** (free tier covers most usage)
- Domain (for privacy policy): **$10-15/year** (optional)

### Total First Year
- Minimum: **$124** (Google + Apple + Maps free tier)
- With optional items: **$200-400**

---

## Part 9: Resources

### Design Tools
- [App Icon Generator](https://appicon.co/) - Free icon resizing
- [Canva](https://canva.com) - Free graphic design
- [Figma](https://figma.com) - Free design tool
- [Screenshot Framer](https://screenshot.rocks/) - Beautiful screenshots

### Testing
- [Firebase Test Lab](https://firebase.google.com/docs/test-lab) - Free automated testing
- [TestFlight](https://developer.apple.com/testflight/) - iOS beta testing

### Analytics (Optional)
- [Google Analytics for Firebase](https://firebase.google.com/products/analytics) - Free
- [Mixpanel](https://mixpanel.com) - Free tier available

### Crash Reporting
- [Firebase Crashlytics](https://firebase.google.com/products/crashlytics) - Free
- [Sentry](https://sentry.io) - Free tier available

---

## Part 10: Quick Command Reference

```bash
# Initial setup
flutter pub get

# Test on device
flutter run --release

# Build for stores
flutter build appbundle --release  # Android
flutter build ipa --release        # iOS

# Check app size
flutter build appbundle --release --analyze-size

# Run tests
flutter test

# Check for issues
flutter doctor
flutter analyze

# Clean build
flutter clean
flutter pub get
flutter build appbundle --release
```

---

## 🎉 You're Ready to Launch!

Follow this guide step by step, and you'll have your app live on both stores within a week. Good luck! 🚀

For questions, refer to:
- [Flutter Deployment Docs](https://docs.flutter.dev/deployment)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect/)
