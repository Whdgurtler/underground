# 🚀 DEPLOYMENT QUICK START - Underground Toronto

**This is your express guide to getting on the App Store and Play Store FAST!**

---

## ⚡ THE FASTEST PATH TO STORES (1 Day)

### Morning: Setup & Build (3-4 hours)

#### 1. Get Google Maps API Key (15 min)
```bash
1. Go to: https://console.cloud.google.com/
2. Create new project
3. Enable: Maps SDK for Android, Maps SDK for iOS
4. Create API Key
5. Add to android/app/src/main/AndroidManifest.xml (line with YOUR_GOOGLE_MAPS_API_KEY_HERE)
6. Add to ios/Runner/AppDelegate.swift (line with YOUR_GOOGLE_MAPS_API_KEY_HERE)
```

#### 2. Android Signing (20 min)
```bash
# Generate keystore
cd android/app
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Create android/key.properties
echo "storePassword=YOUR_PASSWORD" > ../key.properties
echo "keyPassword=YOUR_PASSWORD" >> ../key.properties
echo "keyAlias=upload" >> ../key.properties
echo "storeFile=upload-keystore.jks" >> ../key.properties
```

**⚠️ SAVE YOUR PASSWORD! You'll need it forever!**

#### 3. Build Android (15 min)
```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

#### 4. Build iOS - Mac Only (30 min)
```bash
# Install pods
cd ios && pod install && cd ..

# Build
flutter build ipa --release
```

Or use Xcode:
1. Open `ios/Runner.xcworkspace`
2. Select your team
3. Product → Archive
4. Distribute → App Store

#### 5. Create App Icons (30 min)
Use Canva.com (free):
1. Create 1024x1024 image
2. Use blue background (#004C97)
3. Add map icon + location pin
4. Download PNG

Or use this quick trick:
- Just use a placeholder for now
- Update later after approval

#### 6. Take Screenshots (30 min)
```bash
# Run app on phone
flutter run --release

# Take 4-5 screenshots showing:
1. Main map with GPS
2. Underground mode (orange)
3. Info panel
4. Path tracking
5. Status bar
```

### Afternoon: Upload to Stores (2-3 hours)

#### 7. Google Play Console (1 hour)
```
1. Go to: https://play.google.com/console
2. Pay $25 (one-time)
3. Create new app: "Underground Toronto Navigator"
4. Upload app-release.aab
5. Add 2+ screenshots
6. Copy description from STORE_LISTINGS.md
7. Add privacy policy URL (use GitHub Pages)
8. Submit!
```

**Review time: 1-3 days**

#### 8. Apple App Store (1-2 hours)
```
1. Go to: https://appstoreconnect.apple.com
2. Pay $99 (annual)
3. Create new app
4. Upload IPA (via Xcode or Transporter)
5. Add 3+ screenshots (iPhone 6.7" required)
6. Copy description from STORE_LISTINGS.md
7. Privacy policy URL
8. Submit!
```

**Review time: 1-7 days (usually 2-3)**

---

## 📋 THE ABSOLUTE MINIMUM YOU NEED

### To Build:
- ✅ Flutter installed
- ✅ Google Maps API key
- ✅ Android signing keystore
- ✅ iOS team selected (Mac only)

### To Submit:
- ✅ Built .aab (Android) or .ipa (iOS)
- ✅ 2+ screenshots
- ✅ App description
- ✅ Privacy policy URL
- ✅ Developer account ($25 Play, $99 Apple)

---

## 💰 TOTAL COST

| Item | Cost |
|------|------|
| Google Play | $25 (once) |
| Apple App Store | $99/year |
| Google Maps API | $0 (free tier) |
| **TOTAL** | **$124 first year** |

---

## 🔑 CRITICAL: DON'T LOSE THESE!

1. **Android Keystore Password** - You can NEVER change this
2. **Keystore File** - Back it up NOW
3. **Apple Developer Account** - Keep it active
4. **Google Maps API Key** - Don't expose it publicly

---

## 📝 COPY-PASTE READY CONTENT

### Short Description (both stores)
```
Navigate Toronto's underground PATH system with GPS and sensor technology
```

### App Title
```
Underground Toronto Navigator
```

### Privacy Policy Quick Version
```
This app uses GPS and motion sensors to track your position for navigation. 
All data stays on your device. We don't collect, store, or share your data.
For full policy, visit: [YOUR_GITHUB_URL]/PRIVACY_POLICY.md
```

Host privacy policy on GitHub Pages (free):
1. Enable GitHub Pages in repo settings
2. Link to: `https://yourusername.github.io/underground-toronto/PRIVACY_POLICY`

---

## 🆘 IF SOMETHING BREAKS

### Build fails?
```bash
flutter clean
flutter pub get
flutter doctor
# Fix any issues shown
flutter build appbundle --release
```

### Can't sign Android?
- Check `android/key.properties` exists
- Verify password is correct
- Make sure keystore file is in `android/app/`

### iOS won't build?
- Open Xcode and select your team
- Run `pod install` in ios folder
- Make sure Apple Developer account is active

### Maps don't load?
- Check API key is correct
- Enable APIs in Google Cloud Console
- Remove any unnecessary restrictions on API key

---

## 🎯 THE 1-HOUR SUBMIT

If you're REALLY in a hurry and just want to submit (quality comes later):

**Hour 1: Android Only**
```bash
# Minute 0-10: Setup
flutter pub get
# Get Google Maps key, add to AndroidManifest.xml

# Minute 10-25: Signing
cd android/app
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
# Create key.properties

# Minute 25-40: Build
flutter build appbundle --release

# Minute 40-60: Submit
# Go to Play Console
# Upload .aab
# Use minimal screenshots (phone screen captures)
# Copy-paste description
# Submit!
```

**You're live on Android in 1-3 days!**

---

## 📱 TEST BEFORE SUBMITTING

**Critical Test: Release Build**
```bash
# Android
flutter build apk --release
flutter install

# iOS
flutter build ipa --release
# Install via Xcode or TestFlight
```

**Must Work:**
- ✅ App opens
- ✅ Permissions requested
- ✅ Map loads
- ✅ GPS tracking works
- ✅ No crashes

---

## 🚦 REVIEW TIMELINE

### Google Play
- **Upload:** Instant
- **Review:** 1-3 days (often same day!)
- **Published:** Immediately after approval
- **Updates:** Same timeline

### Apple App Store
- **Upload:** 10-30 min processing
- **Review:** 1-7 days (average 2-3 days)
- **Published:** Immediately or scheduled
- **Updates:** Same timeline

**Tip:** Submit to both stores same day for coordinated launch!

---

## ✅ DONE? WHAT'S NEXT?

After submission:
1. ⏰ **Wait** - Check email for updates
2. 📧 **Respond** - Answer any reviewer questions quickly
3. 📊 **Monitor** - Watch crash reports and reviews
4. 🎉 **Celebrate** - You shipped a real app!
5. 📣 **Market** - Share on social media
6. 🔧 **Iterate** - Plan v1.1 based on feedback

---

## 🏁 ONE-COMMAND BUILDS

**Android:**
```bash
flutter clean && flutter pub get && flutter build appbundle --release
```

**iOS:**
```bash
flutter clean && flutter pub get && cd ios && pod install && cd .. && flutter build ipa --release
```

**Both:**
```bash
# Android
flutter clean && flutter pub get && flutter build appbundle --release

# iOS (Mac)
cd ios && pod install && cd .. && flutter build ipa --release
```

---

## 📞 QUICK SUPPORT LINKS

- **Flutter Deployment:** https://docs.flutter.dev/deployment
- **Play Console:** https://play.google.com/console
- **App Store Connect:** https://appstoreconnect.apple.com
- **Google Cloud Console:** https://console.cloud.google.com
- **Detailed Guide:** See DEPLOYMENT.md in this repo

---

## 🎓 GRADUATION CHECKLIST

You're ready to submit when:
- ✅ App builds without errors
- ✅ Tested on real device
- ✅ Signing configured
- ✅ 2+ screenshots taken
- ✅ Description written
- ✅ Privacy policy URL ready

**Don't overthink it! Submit and iterate!**

---

## 💡 PRO TIPS

1. **Start with Android** - Faster approval, easier process
2. **Use placeholders** - You can update everything later
3. **Screenshot early** - Even blank screens with UI work initially
4. **Privacy policy** - Host on GitHub Pages (free)
5. **Test release builds** - Debug builds hide problems
6. **Back up keystore** - You can NEVER recover this
7. **Beta test** - Use TestFlight (iOS) or internal testing (Android)
8. **Monitor reviews** - Respond within 24 hours
9. **Update often** - Shows active development
10. **Ask for reviews** - In-app after positive interactions

---

## 🎬 FINAL WORDS

**DO:**
- ✅ Submit quickly and iterate
- ✅ Respond to user feedback
- ✅ Test on real devices
- ✅ Back up your keystore
- ✅ Keep API keys secret

**DON'T:**
- ❌ Commit keystore to Git
- ❌ Expose API keys publicly
- ❌ Skip testing release builds
- ❌ Ignore crash reports
- ❌ Wait for perfection

---

## 🚀 READY? LET'S GO!

1. **Right now:** Run `flutter pub get`
2. **Next 10 minutes:** Get Google Maps API key
3. **Next hour:** Build your releases
4. **Tonighttonight:** Submit to stores
5. **This week:** You're published!

**You've got this! 🎉**

For detailed instructions on any step, see:
- `DEPLOYMENT.md` - Complete guide
- `DEPLOYMENT_CHECKLIST.md` - Item-by-item checklist
- `STORE_LISTINGS.md` - Copy-paste store content
- `APP_ICONS.md` - Icon creation guide
- `PRIVACY_POLICY.md` - Privacy policy template

---

**Need help? Open an issue on GitHub or email: support@undergroundtoronto.app**

**Built with ❤️ for Toronto's underground explorers**
