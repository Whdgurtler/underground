# Underground Toronto - Quick Start Guide

## What You've Built 🎉

A complete Flutter app that can navigate underground areas using:
- **GPS** for above-ground positioning
- **Accelerometer & Gyroscope** for underground dead reckoning
- **Automatic switching** between modes
- **Real-time visualization** on Google Maps

## Quick Start (5 Minutes)

### Step 1: Install Flutter (if needed)
```bash
# Check if Flutter is installed
flutter --version

# If not installed, download from: https://flutter.dev/docs/get-started/install
```

### Step 2: Get Dependencies
```bash
cd "C:\Users\whdgu\OneDrive\Desktop\UNDERGROUND"
flutter pub get
```

### Step 3: Get Google Maps API Key (Free)
1. Visit: https://console.cloud.google.com/
2. Create a new project
3. Enable "Maps SDK for Android" and "Maps SDK for iOS"
4. Create API Key (Credentials → Create Credentials → API Key)
5. Copy your API key

### Step 4: Add API Key

**Android**: Edit `android/app/src/main/AndroidManifest.xml`
Find this line and replace with your key:
```xml
android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE"
```

**iOS**: Edit `ios/Runner/AppDelegate.swift`
Find this line and replace with your key:
```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY_HERE")
```

### Step 5: Run!
```bash
# Connect your phone via USB (with USB debugging enabled)
flutter devices
flutter run
```

## Testing the App

### 1. Above Ground Test (GPS Mode)
- Go outside
- Open the app
- Grant location permissions
- Watch the blue marker track your movement
- Status bar shows "GPS ACTIVE" in green

### 2. Underground Test (Accelerometer Mode)
- Enter a building or underground parking
- Wait 30 seconds for GPS loss detection
- Status bar changes to "UNDERGROUND MODE" in orange
- Marker changes to orange
- Walk around - the app estimates your position using sensors

### 3. Toronto PATH Test (Real World!)
- Start at any PATH entrance in downtown Toronto
- Let GPS lock above ground
- Enter the PATH
- Navigate using accelerometer estimates
- Exit and watch it switch back to GPS

## Key Features

### Status Indicators
- 🟢 Green Bar = GPS Active
- 🟠 Orange Bar = Underground Mode
- 🔵 Blue Marker = GPS Position
- 🟠 Orange Marker = Estimated Position

### Buttons
- **Location Button**: Center map on your position
- **Calibrate Button**: Reset sensor drift
- **Refresh Button**: Reset tracking

### Info Panel (Bottom)
- Position source (GPS/Accelerometer)
- Latitude, Longitude, Altitude
- GPS accuracy
- Distance traveled underground
- Current heading

## Tips for Best Results

1. **Start Above Ground**: Always start tracking with GPS before going underground
2. **Calibrate Often**: Use the calibrate button every 1-2 minutes underground
3. **Walk Steadily**: Consistent walking pace gives better estimates
4. **Avoid Running**: Quick movements decrease accuracy
5. **Trust GPS First**: When back above ground, GPS will automatically take over

## How It Works

### GPS Mode (Above Ground)
```
GPS Satellite → Device GPS → App → Map Update
```

### Underground Mode
```
Accelerometer → Measure Movement → Calculate Displacement → Estimate Position → Map Update
```

### Detection Logic
Underground detected when:
- GPS signal lost > 30 seconds
- GPS accuracy drops below 50m repeatedly
- Average accuracy degrades significantly

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Map won't load | Check API key is correct |
| No location updates | Enable location permissions |
| GPS not working | Go outside, wait for fix |
| App won't build | Run `flutter clean && flutter pub get` |
| Drift underground | Use calibrate button regularly |

## System Requirements

### Minimum
- Android 5.0 (API 21) or iOS 12.0
- GPS capability
- Accelerometer sensor
- Gyroscope sensor
- Internet connection (for maps)

### Recommended
- Android 8.0+ or iOS 14.0+
- Good GPS reception
- Modern sensors (post-2018)
- 4G/5G or WiFi

## Free & Open Software Used ✅

All dependencies are free and open source:
- Flutter SDK - BSD License
- Dart SDK - BSD License
- geolocator - MIT License
- sensors_plus - BSD License
- google_maps_flutter - BSD License
- provider - MIT License
- permission_handler - MIT License

**Google Maps**: Free tier includes:
- 28,000 map loads per month
- $200 free credit monthly
- More than enough for personal use!

## What's Next?

### Easy Enhancements
- Add offline maps
- Save and share paths
- Add waypoints/markers
- Record walking routes

### Advanced Features
- Integrate Bluetooth beacons
- Add step detection
- Multi-floor support
- PATH map overlay

## Project Structure

```
underground-toronto/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/
│   │   └── position.dart        # Data models
│   ├── services/
│   │   ├── location_service.dart        # GPS handling
│   │   ├── accelerometer_service.dart   # Sensor tracking
│   │   └── underground_detector.dart    # Detection logic
│   └── screens/
│       └── navigation_screen.dart       # Main UI
├── android/                      # Android configuration
├── ios/                          # iOS configuration
├── assets/                       # Images and maps
└── pubspec.yaml                  # Dependencies
```

## Getting Help

1. Read the detailed [README.md](README.md)
2. Check [SETUP.md](SETUP.md) for detailed setup
3. Review Flutter docs: https://flutter.dev/docs
4. Check sensor packages:
   - Geolocator: https://pub.dev/packages/geolocator
   - Sensors Plus: https://pub.dev/packages/sensors_plus

## Contributing

Want to improve the app? Check the README for contribution guidelines!

---

**Happy Underground Navigation! 🗺️🚇**

Built for Toronto's PATH system and beyond!
