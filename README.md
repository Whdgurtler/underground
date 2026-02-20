# Underground Toronto Navigator 🗺️

A sophisticated Flutter mobile application for navigating underground Toronto, specifically designed to work in the PATH system and other underground locations where GPS signals are unavailable.

## 🌟 Features

- **GPS Tracking**: Real-time location tracking using device GPS when above ground
- **Accelerometer-Based Dead Reckoning**: Estimates position using accelerometer and gyroscope data when GPS is unavailable
- **Automatic Underground Detection**: Intelligently detects when you've gone underground based on GPS signal quality and availability
- **Visual Path Tracking**: See your complete path with different colors for GPS vs. estimated positions
- **Real-time Position Updates**: Live updates of your latitude, longitude, altitude, and heading
- **Sensor Calibration**: Manual calibration to reduce drift in accelerometer estimates
- **Interactive Map**: Google Maps integration with custom markers and path visualization

## 🏗️ Architecture

The app is built with a clean, modular architecture:

### Services Layer
- **LocationService**: Manages GPS tracking and permissions
- **AccelerometerService**: Implements dead reckoning using device sensors
- **UndergroundDetector**: Detects underground transitions based on GPS signal analysis

### Models
- **Position**: Represents a location with source tracking (GPS/Accelerometer/Estimated)
- **MovementData**: Stores acceleration, velocity, and displacement vectors
- **NavigationState**: Current navigation state including underground status

### UI
- **NavigationScreen**: Main screen with map, status bar, and info panel
- Real-time updates using Provider state management

## 📋 Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / Xcode for mobile development
- Google Maps API Key (free tier available)

## 🚀 Getting Started

### Quick Links
- **📱 Deploy to stores:** See [DEPLOY_NOW.md](DEPLOY_NOW.md) for fastest path
- **📋 Full deployment guide:** See [DEPLOYMENT.md](DEPLOYMENT.md) for complete instructions
- **✅ Deployment checklist:** See [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) for step-by-step
- **🎨 Create app icons:** See [APP_ICONS.md](APP_ICONS.md) for icon design
- **📝 Store listings:** See [STORE_LISTINGS.md](STORE_LISTINGS.md) for copy-paste content
- **🔒 Privacy policy:** See [PRIVACY_POLICY.md](PRIVACY_POLICY.md) for template

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/underground-toronto.git
cd underground-toronto
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Set Up Google Maps

#### Android
1. Get a Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Open `android/app/src/main/AndroidManifest.xml`
3. Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual API key

#### iOS
1. Open `ios/Runner/AppDelegate.swift` (create if needed)
2. Add your Google Maps API key:
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
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 4. Run the App
```bash
# For Android
flutter run

# For iOS (Mac only)
flutter run -d ios

# For specific device
flutter devices
flutter run -d <device_id>
```

## 🧪 Testing

### On a Real Device (Recommended)
The app works best on a physical device with GPS and accelerometer sensors:

1. **Above Ground Testing**:
   - Walk outside and observe GPS tracking (blue markers)
   - Check accuracy in the info panel

2. **Underground Testing**:
   - Enter a building or underground area
   - Watch as the app switches to accelerometer mode (orange markers)
   - Walk around to see dead reckoning in action

3. **PATH System** (Toronto):
   - Start above ground near a PATH entrance (downtown Toronto)
   - Enter the PATH and watch the automatic transition
   - Navigate using the estimated position

### Simulating Underground Conditions
To test without going underground:
- Turn off location services temporarily
- Use "Simulate Location" in developer options (Android)
- The app will automatically switch to accelerometer mode

## 📱 Permissions

The app requires the following permissions:

### Android
- `ACCESS_FINE_LOCATION`: For precise GPS
- `ACCESS_COARSE_LOCATION`: For approximate location
- `ACCESS_BACKGROUND_LOCATION`: For continuous tracking
- `ACTIVITY_RECOGNITION`: For motion sensors
- `INTERNET`: For map tiles

### iOS
- Location (When In Use): Basic location access
- Location (Always): Background tracking
- Motion & Fitness: Accelerometer and gyroscope access

## 🔧 How It Works

### 1. GPS Mode (Above Ground)
- Uses device GPS for accurate positioning
- Updates location every 1 meter of movement
- Tracks accuracy and signal strength

### 2. Underground Detection
The app uses multiple signals to detect underground transitions:
- GPS signal loss for >30 seconds
- Consecutive low-accuracy readings (>50m)
- Significant accuracy degradation over time

### 3. Accelerometer Mode (Underground)
When underground, the app:
1. Records the last known GPS position as a base
2. Uses accelerometer to measure acceleration
3. Integrates twice to calculate displacement
4. Uses gyroscope to determine heading
5. Updates position relative to the base location

### 4. Dead Reckoning Algorithm
```
velocity(t) = velocity(t-1) + acceleration * dt
position(t) = position(t-1) + velocity * dt
```
With:
- Gravity compensation
- Noise filtering
- Drift compensation (0.98 decay factor)

## 🎯 Key Features Explained

### Automatic Mode Switching
- Seamlessly transitions between GPS and accelerometer
- Resets accelerometer base when GPS becomes available
- No manual intervention required

### Drift Compensation
- Accelerometer drift is natural due to sensor noise
- App applies 0.98 decay factor to velocity
- Manual calibration available via button

### Visual Feedback
- **Blue markers/path**: GPS-based position
- **Orange markers/path**: Accelerometer-based estimate
- **Green status bar**: GPS active
- **Orange status bar**: Underground mode

## 📊 Accuracy

### GPS Mode
- Typical accuracy: 5-20 meters
- Best case: <5 meters (clear sky)
- Urban canyon: 20-50 meters

### Accelerometer Mode
- Initial accuracy: Very good (first 30 seconds)
- Medium term: Moderate (1-2 minutes)
- Long term: Degrades over time due to drift
- **Recommendation**: Re-calibrate every 1-2 minutes

## 🔮 Future Enhancements

- [ ] Offline map support for underground areas
- [ ] PATH system map overlay
- [ ] Bluetooth beacon integration for improved accuracy
- [ ] Step detection and pedestrian dead reckoning
- [ ] Compass integration for better heading
- [ ] Multiple floor support
- [ ] Point of Interest database for PATH
- [ ] Navigation routing in underground spaces
- [ ] Historical path saving and sharing

## 🛠️ Troubleshooting

### GPS Not Working
- Check location permissions in device settings
- Ensure location services are enabled
- Go outside for better satellite visibility

### Accelerometer Not Tracking
- Check motion/fitness permissions
- Restart the app
- Calibrate sensors using the calibration button

### Map Not Loading
- Verify Google Maps API key is correct
- Check internet connection
- Ensure API is enabled in Google Cloud Console

### Poor Accuracy Underground
- Start above ground before going underground
- Calibrate sensors regularly
- Walk at a steady pace
- Avoid rapid movements

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 👏 Acknowledgments

- Flutter team for the amazing framework
- Google Maps Platform for mapping services
- Geolocator and Sensors Plus packages
- Toronto PATH system inspiration

## 📧 Contact

For questions or feedback, please open an issue on GitHub.

---

**Note**: This app is designed for emergency navigation and exploration purposes. For critical navigation, always carry a physical map or use traditional methods as backup.

Made with ❤️ for Toronto's underground navigation
