# PowerShell script for building both Android and iOS releases on Windows

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   Underground Toronto Navigator - Complete Build Script    " -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Check if Flutter is installed
$flutterExists = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterExists) {
    Write-Host "❌ Flutter not found!" -ForegroundColor Red
    Write-Host "Install from: https://flutter.dev/docs/get-started/install/windows"
    exit 1
}

Write-Host "✓ Flutter detected" -ForegroundColor Green
flutter --version
Write-Host ""

# Clean previous builds
Write-Host "🧹 Cleaning previous builds..." -ForegroundColor Yellow
flutter clean

# Get dependencies
Write-Host "📦 Getting dependencies..." -ForegroundColor Yellow
flutter pub get

# Analyze code
Write-Host "🔍 Analyzing code..." -ForegroundColor Yellow
flutter analyze

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "                    BUILDING ANDROID                         " -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Check for Android signing
if (-not (Test-Path "android\key.properties")) {
    Write-Host "❌ Warning: android\key.properties not found" -ForegroundColor Red
    Write-Host "Android will build with debug signing only"
    Write-Host "For production, create key.properties file"
    Write-Host ""
    $response = Read-Host "Continue with debug signing? (y/n)"
    if ($response -ne 'y') {
        exit 1
    }
}

Write-Host "📱 Building Android App Bundle..." -ForegroundColor Blue
flutter build appbundle --release

Write-Host "📱 Building Android APKs (split by ABI)..." -ForegroundColor Blue
flutter build apk --release --split-per-abi

Write-Host ""
Write-Host "✅ Android builds complete!" -ForegroundColor Green
Write-Host "  App Bundle: build\app\outputs\bundle\release\app-release.aab"
Write-Host "  APKs: build\app\outputs\flutter-apk\"

# iOS build not supported on Windows
Write-Host ""
Write-Host "ℹ️  iOS builds require macOS with Xcode" -ForegroundColor Yellow
Write-Host "    To build iOS, use a Mac or cloud service like Codemagic"

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "                    BUILD COMPLETE! 🎉                       " -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "All Android builds completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📦 Output files:" -ForegroundColor Cyan
Write-Host "  Android Bundle: build\app\outputs\bundle\release\app-release.aab"
Write-Host "  Android APKs:   build\app\outputs\flutter-apk\"
Write-Host ""
Write-Host "🎯 Next steps:" -ForegroundColor Yellow
Write-Host "  1. Test release APK on real device"
Write-Host "  2. Upload .aab to Google Play Console"
Write-Host "  3. Complete store listing"
Write-Host "  4. Submit for review!"
Write-Host ""
Write-Host "📚 See DEPLOYMENT.md for detailed instructions"
Write-Host ""
Write-Host "Happy publishing! 🚀" -ForegroundColor Green
