# PowerShell script for building Android release on Windows

Write-Host "🚀 Building Underground Toronto Navigator - Android Release" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# Check if key.properties exists
if (-not (Test-Path "android\key.properties")) {
    Write-Host "❌ Error: android\key.properties not found!" -ForegroundColor Red
    Write-Host "Please create this file with your signing credentials:" -ForegroundColor Yellow
    Write-Host "  storePassword=YOUR_KEYSTORE_PASSWORD"
    Write-Host "  keyPassword=YOUR_KEY_PASSWORD"
    Write-Host "  keyAlias=upload"
    Write-Host "  storeFile=upload-keystore.jks"
    Write-Host ""
    Write-Host "Generate keystore with:" -ForegroundColor Yellow
    Write-Host "  keytool -genkey -v -keystore android\app\upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload"
    exit 1
}

Write-Host "✓ Signing configuration found" -ForegroundColor Green

# Clean previous builds
Write-Host ""
Write-Host "🧹 Cleaning previous builds..." -ForegroundColor Yellow
flutter clean

# Get dependencies
Write-Host ""
Write-Host "📦 Getting dependencies..." -ForegroundColor Yellow
flutter pub get

# Analyze code
Write-Host ""
Write-Host "🔍 Analyzing code..." -ForegroundColor Yellow
flutter analyze

# Build App Bundle
Write-Host ""
Write-Host "📱 Building App Bundle (AAB)..." -ForegroundColor Yellow
flutter build appbundle --release

# Build APKs
Write-Host ""
Write-Host "📱 Building split APKs..." -ForegroundColor Yellow
flutter build apk --release --split-per-abi

# Build universal APK
Write-Host ""
Write-Host "📱 Building universal APK..." -ForegroundColor Yellow
flutter build apk --release

# Display results
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "✅ Build completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📦 Output files:" -ForegroundColor Cyan
Write-Host "  App Bundle: build\app\outputs\bundle\release\app-release.aab"
Write-Host "  APKs:"
Write-Host "    - build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk"
Write-Host "    - build\app\outputs\flutter-apk\app-arm64-v8a-release.apk"
Write-Host "    - build\app\outputs\flutter-apk\app-x86_64-release.apk"
Write-Host "    - build\app\outputs\flutter-apk\app-release.apk (universal)"
Write-Host ""

# Get file sizes
if (Test-Path "build\app\outputs\bundle\release\app-release.aab") {
    $aabSize = (Get-Item "build\app\outputs\bundle\release\app-release.aab").Length / 1MB
    Write-Host "📊 App Bundle size: $([math]::Round($aabSize, 2)) MB" -ForegroundColor Cyan
}

if (Test-Path "build\app\outputs\flutter-apk\app-release.apk") {
    $apkSize = (Get-Item "build\app\outputs\flutter-apk\app-release.apk").Length / 1MB
    Write-Host "📊 Universal APK size: $([math]::Round($apkSize, 2)) MB" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "🎯 Next steps:" -ForegroundColor Yellow
Write-Host "  1. Test the APK on a real device"
Write-Host "  2. Upload app-release.aab to Google Play Console"
Write-Host "  3. Fill in store listing details"
Write-Host "  4. Submit for review"
Write-Host ""
Write-Host "Happy publishing! 🚀" -ForegroundColor Green
