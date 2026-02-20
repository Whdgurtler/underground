# 🚀 STORE DEPLOYMENT CHECKLIST

Complete this checklist before submitting to app stores. Check off items as you complete them.

---

## PHASE 1: PREPARATION (Before Building)

### Development Setup
- [ ] Flutter SDK installed and updated (`flutter doctor`)
- [ ] Android Studio or Xcode installed
- [ ] All dependencies installed (`flutter pub get`)
- [ ] App runs successfully in debug mode
- [ ] All features tested on real device
- [ ] No critical bugs remaining

### Code Quality
- [ ] Run `flutter analyze` - no errors
- [ ] Run `flutter test` - all tests pass
- [ ] Code reviewed and cleaned up
- [ ] Removed all debug print statements
- [ ] Removed unused imports and files
- [ ] Comments updated and accurate

### Version & Branding
- [ ] Version number updated in pubspec.yaml (e.g., 1.0.0+1)
- [ ] App name finalized in all config files
- [ ] Bundle identifier/package name confirmed unique
- [ ] Checked for naming conflicts in stores

---

## PHASE 2: GOOGLE MAPS SETUP

### API Configuration
- [ ] Google Cloud Platform account created
- [ ] New project created for the app
- [ ] Maps SDK for Android enabled
- [ ] Maps SDK for iOS enabled
- [ ] Geolocation API enabled (optional but recommended)
- [ ] API key created (with restrictions for security)
- [ ] Billing account linked (free tier is sufficient)

### API Key Integration
- [ ] Android: API key added to AndroidManifest.xml
- [ ] iOS: API key added to AppDelegate.swift
- [ ] API key restrictions configured (Android/iOS app restrictions)
- [ ] Tested map loading on real devices

### API Key Security
- [ ] API key NOT committed to Git
- [ ] API restrictions set up in Google Cloud Console
- [ ] Usage monitoring enabled
- [ ] Billing alerts configured

---

## PHASE 3: ANDROID DEPLOYMENT

### Signing Configuration
- [ ] Upload keystore generated (`keytool -genkey...`)
- [ ] key.properties file created with credentials
- [ ] key.properties added to .gitignore
- [ ] Keystore backed up securely (CRITICAL!)
- [ ] Passwords saved in password manager
- [ ] build.gradle configured for release signing

### App Configuration
- [ ] Application ID finalized and unique
- [ ] targetSdkVersion set to latest (34+)
- [ ] minSdkVersion appropriate (21+)
- [ ] Permissions in AndroidManifest.xml reviewed
- [ ] ProGuard rules configured
- [ ] App name set in strings.xml

### Build Process
- [ ] Run `flutter clean`
- [ ] Run `flutter pub get`
- [ ] Build App Bundle: `flutter build appbundle --release`
- [ ] Build succeeded without errors
- [ ] App Bundle size is reasonable (<150MB)
- [ ] Tested release APK on real device
- [ ] No crashes in release mode
- [ ] All features work in release build

### Google Play Console Setup
- [ ] Google Play Developer account created ($25 paid)
- [ ] New app created in Play Console
- [ ] App category selected (Maps & Navigation)
- [ ] Countries/regions selected for distribution
- [ ] Content rating questionnaire completed
- [ ] Target audience set (13+)

### Store Assets (Android)
- [ ] App icon 512x512 PNG created and uploaded
- [ ] Feature graphic 1024x500 PNG created and uploaded
- [ ] At least 2 screenshots (1080x1920 or 1920x1080)
- [ ] Screenshots show key features
- [ ] Optional: Promo video created (up to 30 seconds)

### Store Listing (Android)
- [ ] App title (50 chars) written
- [ ] Short description (80 chars) written
- [ ] Full description (4000 chars) written
- [ ] Keywords researched and included
- [ ] Contact email provided
- [ ] Privacy policy hosted and URL added
- [ ] Support URL provided (optional)

### Release Configuration (Android)
- [ ] Production release created
- [ ] App Bundle uploaded (.aab file)
- [ ] Release notes written (what's new)
- [ ] Release name set (e.g., "1.0.0")
- [ ] Rollout percentage set (start with 100% or staged)

### Pre-Launch Checklist (Android)
- [ ] Reviewed Play Console pre-launch report
- [ ] Checked for any warning messages
- [ ] Verified all store listing details
- [ ] Confirmed pricing (Free)
- [ ] Checked app visibility settings
- [ ] Screenshots display correctly

### Submit (Android)
- [ ] Final review of everything
- [ ] Clicked "Submit for review"
- [ ] Confirmation email received
- [ ] Estimated review time: 1-3 days

---

## PHASE 4: IOS DEPLOYMENT

### Apple Developer Setup
- [ ] Apple Developer Program membership ($99/year) active
- [ ] Apple ID verified and 2FA enabled
- [ ] Team ID noted
- [ ] Certificates and profiles reviewed

### Xcode Configuration
- [ ] Open ios/Runner.xcworkspace in Xcode
- [ ] Team selected in Signing & Capabilities
- [ ] Bundle Identifier set (must be unique)
- [ ] Deployment target set (iOS 12.0+)
- [ ] App icon assets added to Assets.xcassets
- [ ] Launch screen configured

### Permissions & Info.plist
- [ ] NSLocationWhenInUseUsageDescription added with clear text
- [ ] NSLocationAlwaysAndWhenInUseUsageDescription added
- [ ] NSMotionUsageDescription added with clear text
- [ ] Google Maps API key added to AppDelegate.swift
- [ ] All permission strings are user-friendly

### Build Process (iOS)
- [ ] Run `flutter clean`
- [ ] Run `flutter pub get`
- [ ] Run `cd ios && pod install`
- [ ] Build IPA: `flutter build ipa --release`
- [ ] Build succeeded without errors
- [ ] IPA size is reasonable (<200MB)
- [ ] Tested on real iPhone/iPad device
- [ ] No crashes in release mode

### App Store Connect Setup
- [ ] App Store Connect account access verified
- [ ] New app created in App Store Connect
- [ ] Bundle ID matches Xcode configuration
- [ ] SKU created (can be anything unique)
- [ ] Primary language selected

### Store Assets (iOS)
- [ ] App icon 1024x1024 PNG (no alpha) uploaded
- [ ] iPhone 6.7" screenshots (1290x2796) - 3 required
- [ ] iPhone 6.5" screenshots (1242x2688) - 3 required
- [ ] iPad screenshots if supporting iPad
- [ ] Screenshots show key features
- [ ] Optional: App preview video (up to 30 seconds)

### Store Listing (iOS)
- [ ] App name (30 chars) written
- [ ] Subtitle (30 chars) written
- [ ] Promotional text (170 chars) written
- [ ] Description (4000 chars) written
- [ ] Keywords (100 chars) written - no spaces between commas
- [ ] Privacy policy URL added
- [ ] Support URL added
- [ ] Marketing URL added (optional)

### App Information (iOS)
- [ ] Primary category: Navigation
- [ ] Secondary category: Travel
- [ ] Age rating completed (should be 4+)
- [ ] Copyright information added
- [ ] Contact information for app review

### Build Upload (iOS)
- [ ] Archive created in Xcode (Product → Archive)
- [ ] Archive validated successfully
- [ ] Build uploaded to App Store Connect
- [ ] Or: IPA uploaded via Transporter app
- [ ] Build processing completed (wait 10-30 minutes)
- [ ] Build appears in App Store Connect

### App Review Information (iOS)
- [ ] Review notes added explaining the app
- [ ] Test account provided if needed (N/A for this app)
- [ ] Contact information for reviewer
- [ ] Demo video or instructions if features are complex
- [ ] Explained GPS and sensor usage clearly

### Export Compliance (iOS)
- [ ] Export compliance information completed
- [ ] Selected "No" if only using standard encryption (HTTPS)
- [ ] Or completed compliance if using custom encryption

### Release Configuration (iOS)
- [ ] Build selected for submission
- [ ] Version release set (automatic or manual)
- [ ] Pricing set (Free)
- [ ] Availability in countries selected

### Pre-Launch Checklist (iOS)
- [ ] All sections show green checkmarks
- [ ] No missing information warnings
- [ ] Screenshots display correctly in preview
- [ ] App icon shows correctly
- [ ] Description and metadata reviewed

### Submit (iOS)
- [ ] Final review of everything
- [ ] Clicked "Submit for Review"
- [ ] Confirmation received
- [ ] App status changed to "Waiting for Review"
- [ ] Estimated review time: 1-7 days (average 2-3)

---

## PHASE 5: LEGAL & COMPLIANCE

### Privacy Policy
- [ ] Privacy policy written (use template provided)
- [ ] Hosted on website or GitHub Pages
- [ ] URL accessible and working
- [ ] Updated date included
- [ ] Covers all data collection (location, sensors)
- [ ] Explains third-party services (Google Maps)
- [ ] Contact information included

### Terms of Service (Optional)
- [ ] Terms of service written if needed
- [ ] Hosted and accessible
- [ ] Covers liability disclaimers
- [ ] Usage restrictions if any

### Compliance
- [ ] GDPR compliance reviewed (EU users)
- [ ] CCPA compliance reviewed (California users)
- [ ] COPPA compliant (no tracking of children)
- [ ] Accessibility features considered
- [ ] Local laws reviewed for target markets

### Disclaimers
- [ ] Accuracy disclaimer added about GPS/sensor estimates
- [ ] Liability disclaimer for injuries or damages
- [ ] "Use at your own risk" warning if appropriate

---

## PHASE 6: MARKETING & SUPPORT

### Website
- [ ] Landing page created (optional but recommended)
- [ ] Privacy policy page live
- [ ] Support page with FAQs
- [ ] App download links
- [ ] Contact form or email
- [ ] Google Analytics set up (optional)

### Support
- [ ] Support email address created and monitored
- [ ] Response template prepared for common questions
- [ ] FAQ document created
- [ ] Troubleshooting guide prepared

### Social Media (Optional)
- [ ] Twitter/X account created
- [ ] Instagram account created
- [ ] Facebook page created
- [ ] Reddit presence in r/toronto
- [ ] Launch announcement prepared

### Press & Outreach
- [ ] Press release written
- [ ] Tech blogs/websites identified for outreach
- [ ] Toronto-focused media contacted
- [ ] App review sites submitted to
- [ ] University/community groups notified

---

## PHASE 7: POST-LAUNCH

### Monitoring (First Week)
- [ ] Check app store reviews daily
- [ ] Monitor crash reports (Play Console, App Store Connect)
- [ ] Respond to user feedback
- [ ] Monitor download numbers
- [ ] Check for any critical bugs
- [ ] Monitor API usage and costs

### User Feedback
- [ ] Set up system to collect feedback
- [ ] Respond to app reviews (especially negative ones)
- [ ] Create GitHub issues for bug reports
- [ ] Thank users for positive reviews

### Analytics (Optional)
- [ ] Firebase Analytics integrated (optional)
- [ ] User behavior tracked (with consent)
- [ ] Feature usage analyzed
- [ ] Crash patterns identified

### Iteration
- [ ] List improvements based on feedback
- [ ] Plan version 1.1 features
- [ ] Bug fixes prioritized
- [ ] Performance improvements planned

---

## PHASE 8: FIRST UPDATE

### Planning
- [ ] Decide what to fix/improve
- [ ] Update version number (e.g., 1.0.0 → 1.0.1)
- [ ] Increment build number (+1)
- [ ] Test new changes thoroughly

### Release
- [ ] Build new release (same process as above)
- [ ] Write clear release notes
- [ ] Upload to stores
- [ ] Update store screenshots if features changed
- [ ] Announce update to users

---

## BACKUP & RECOVERY

### Critical Backups
- [ ] Android keystore backed up (CRITICAL!)
- [ ] iOS certificates backed up
- [ ] API keys documented
- [ ] Passwords in password manager
- [ ] Source code in Git remote (GitHub)
- [ ] Store listing content saved
- [ ] Screenshots and graphics saved

### Documentation
- [ ] All credentials documented securely
- [ ] Build process documented
- [ ] Known issues documented
- [ ] Future improvements list maintained

---

## ESTIMATED TIMELINE

| Task | Time Estimate |
|------|--------------|
| Prepare code & assets | 2-4 hours |
| Create signing keys | 30 minutes |
| Configure Google Maps | 30 minutes |
| Build releases | 30 minutes |
| Create store listings | 2-3 hours |
| Take screenshots | 1 hour |
| Write descriptions | 1-2 hours |
| Privacy policy | 1 hour |
| Upload to stores | 1 hour |
| **Total work time** | **8-12 hours** |
| Google Play review | 1-3 days |
| Apple review | 1-7 days |
| **Total calendar time** | **3-10 days** |

---

## COSTS SUMMARY

| Item | Cost | Frequency |
|------|------|-----------|
| Google Play Developer | $25 | One-time |
| Apple Developer Program | $99 | Annual |
| Google Maps API | $0-20 | Monthly |
| Domain (optional) | $10-15 | Annual |
| **Year 1 Total** | **$124-159** | - |
| **Subsequent Years** | **$99-234** | - |

---

## TROUBLESHOOTING

### Build Failed
- Run `flutter clean && flutter pub get`
- Check for any package version conflicts
- Update Flutter SDK: `flutter upgrade`
- Check Android SDK and Xcode are updated

### Signing Errors (Android)
- Verify key.properties exists and has correct credentials
- Check keystore file path is correct
- Ensure keystore password is correct

### Provisioning Errors (iOS)
- Check Apple Developer membership is active
- Verify team is selected in Xcode
- Regenerate provisioning profiles if needed
- Check bundle ID is unique

### Google Maps Not Loading
- Verify API key is correct
- Check APIs are enabled in Cloud Console
- Verify API key restrictions allow your app
- Check internet connection on device

### Review Rejection
- Read rejection reason carefully
- Address specific concerns
- Add clarification in review notes
- Resubmit with fixes

---

## QUICK COMMAND REFERENCE

```bash
# Check Flutter installation
flutter doctor -v

# Clean and get dependencies
flutter clean && flutter pub get

# Analyze code
flutter analyze

# Run tests
flutter test

# Build Android
flutter build appbundle --release
flutter build apk --release --split-per-abi

# Build iOS
flutter build ipa --release

# Check app size
flutter build appbundle --analyze-size

# Generate app icons
flutter pub run flutter_launcher_icons
```

---

## SUCCESS CRITERIA

Your app is ready to submit when:
- ✅ All checklist items above are completed
- ✅ App runs without crashes on real devices
- ✅ All features work as expected
- ✅ Store listings are complete and professional
- ✅ Privacy policy is live and linked
- ✅ Screenshots showcase key features
- ✅ Signing is configured correctly
- ✅ You've tested the release build thoroughly

---

## FINAL PRE-SUBMISSION CHECK

Right before clicking "Submit":
1. ✅ Tested release build on real device
2. ✅ All store assets uploaded
3. ✅ Description has no typos
4. ✅ Privacy policy URL works
5. ✅ Contact email is monitored
6. ✅ Version number is correct
7. ✅ Screenshots show actual app features
8. ✅ Ready to respond to reviews

---

## 🎉 READY TO LAUNCH!

If you've completed all items above, you're ready to submit to the stores!

**Good luck with your launch! 🚀**

Remember:
- First reviews typically within 1-3 days (Android) and 1-7 days (iOS)
- Respond quickly to any reviewer questions
- Monitor crash reports closely after launch
- Be ready to push updates if needed

---

**Questions? Check DEPLOYMENT.md for detailed instructions on any step.**
