# Setup Guide for Underground Toronto Navigator

## Quick Setup Script

Follow these steps to get your app running:

### 1. Install Flutter
If you haven't installed Flutter yet:

**Windows:**
```powershell
# Download Flutter SDK from https://flutter.dev/docs/get-started/install/windows
# Extract to C:\flutter
# Add to PATH: C:\flutter\bin

# Verify installation
flutter doctor
```

**macOS/Linux:**
```bash
# Download Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

### 2. Install Dependencies
```bash
cd underground-toronto
flutter pub get
```

### 3. Get Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable these APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Geolocation API
4. Create credentials (API Key)
5. Copy your API key

### 4. Configure API Keys

**For Android:**
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

**For iOS:**
Create/edit `ios/Runner/AppDelegate.swift`:
```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 5. Build and Run

**For Android:**
```bash
flutter run
```

**For iOS (macOS only):**
```bash
cd ios
pod install
cd ..
flutter run
```

## Troubleshooting

### Flutter Doctor Issues
Run `flutter doctor` and follow suggestions to install missing dependencies.

### Android SDK Issues
```bash
flutter doctor --android-licenses
```

### iOS CocoaPods Issues
```bash
cd ios
pod repo update
pod install
cd ..
```

### Build Errors
```bash
flutter clean
flutter pub get
flutter run
```

## Device Setup

### Android
1. Enable Developer Mode: Settings > About Phone > Tap "Build Number" 7 times
2. Enable USB Debugging: Settings > Developer Options > USB Debugging
3. Connect device via USB
4. Run `flutter devices` to verify connection

### iOS
1. Open Xcode
2. Sign in with Apple ID
3. Open project in Xcode: `open ios/Runner.xcworkspace`
4. Select your team in Signing & Capabilities
5. Connect device and trust computer

## Testing Checklist

- [ ] App builds successfully
- [ ] Location permission requested on first launch
- [ ] Map displays correctly
- [ ] GPS updates position (test outdoors)
- [ ] Underground mode activates (test in building or disable GPS)
- [ ] Path tracking shows on map
- [ ] Calibration button works
- [ ] Info panel shows accurate data

## Next Steps

1. Test GPS tracking outdoors
2. Test underground mode in a building
3. Visit Toronto PATH system for real-world testing
4. Report any issues on GitHub

## Support

For issues or questions:
- Check the main README.md
- Review Flutter documentation: https://flutter.dev/docs
- Open an issue on GitHub

Happy navigating! 🗺️
