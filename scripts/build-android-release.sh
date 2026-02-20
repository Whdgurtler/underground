#!/bin/bash

# Android Release Build Script
# This script builds a release version of the Android app

set -e  # Exit on error

echo "🚀 Building Underground Toronto Navigator - Android Release"
echo "============================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if key.properties exists
if [ ! -f "android/key.properties" ]; then
    echo -e "${RED}❌ Error: android/key.properties not found!${NC}"
    echo "Please create this file with your signing credentials:"
    echo "  storePassword=YOUR_KEYSTORE_PASSWORD"
    echo "  keyPassword=YOUR_KEY_PASSWORD"
    echo "  keyAlias=upload"
    echo "  storeFile=upload-keystore.jks"
    exit 1
fi

# Check if keystore exists
KEYSTORE_FILE=$(grep storeFile android/key.properties | cut -d'=' -f2)
if [ ! -f "android/app/$KEYSTORE_FILE" ]; then
    echo -e "${RED}❌ Error: Keystore file not found: android/app/$KEYSTORE_FILE${NC}"
    echo "Generate it with:"
    echo "  keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload"
    exit 1
fi

echo -e "${GREEN}✓ Signing configuration verified${NC}"

# Clean previous builds
echo ""
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo ""
echo "📦 Getting dependencies..."
flutter pub get

# Analyze code
echo ""
echo "🔍 Analyzing code..."
flutter analyze
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}⚠️  Warning: Code analysis found issues${NC}"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Build App Bundle (recommended for Play Store)
echo ""
echo "📱 Building App Bundle (AAB)..."
flutter build appbundle --release

# Build APKs (split by ABI for smaller downloads)
echo ""
echo "📱 Building APKs..."
flutter build apk --release --split-per-abi

# Build universal APK
echo ""
echo "📱 Building universal APK..."
flutter build apk --release

# Display results
echo ""
echo "============================================================"
echo -e "${GREEN}✅ Build completed successfully!${NC}"
echo ""
echo "📦 Output files:"
echo "  App Bundle: build/app/outputs/bundle/release/app-release.aab"
echo "  APKs:"
echo "    - build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk"
echo "    - build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"
echo "    - build/app/outputs/flutter-apk/app-x86_64-release.apk"
echo "    - build/app/outputs/flutter-apk/app-release.apk (universal)"
echo ""

# Get file sizes
AAB_SIZE=$(du -h build/app/outputs/bundle/release/app-release.aab | cut -f1)
APK_SIZE=$(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)

echo "📊 File sizes:"
echo "  App Bundle: $AAB_SIZE"
echo "  Universal APK: $APK_SIZE"
echo ""

echo "🎯 Next steps:"
echo "  1. Test the APK on a real device"
echo "  2. Upload app-release.aab to Google Play Console"
echo "  3. Fill in store listing details"
echo "  4. Submit for review"
echo ""
echo -e "${GREEN}Happy publishing! 🚀${NC}"
