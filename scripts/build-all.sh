#!/bin/bash

# Complete Build Script - Builds both Android and iOS releases
# Run this script to build production-ready releases for both platforms

set -e

echo "════════════════════════════════════════════════════════════"
echo "   Underground Toronto Navigator - Complete Build Script    "
echo "════════════════════════════════════════════════════════════"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter not found!${NC}"
    echo "Install from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo -e "${GREEN}✓ Flutter detected${NC}"
flutter --version
echo ""

# Clean previous builds
echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
flutter clean

# Get dependencies
echo -e "${YELLOW}📦 Getting dependencies...${NC}"
flutter pub get

# Analyze code
echo -e "${YELLOW}🔍 Analyzing code...${NC}"
flutter analyze

# Run tests if any exist
if [ -d "test" ] && [ "$(ls -A test)" ]; then
    echo -e "${YELLOW}🧪 Running tests...${NC}"
    flutter test
fi

echo ""
echo "════════════════════════════════════════════════════════════"
echo "                    BUILDING ANDROID                         "
echo "════════════════════════════════════════════════════════════"
echo ""

# Check for Android signing
if [ ! -f "android/key.properties" ]; then
    echo -e "${RED}❌ Warning: android/key.properties not found${NC}"
    echo "Android will build with debug signing only"
    echo "For production, create key.properties file"
    echo ""
    read -p "Continue with debug signing? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo -e "${BLUE}📱 Building Android App Bundle...${NC}"
flutter build appbundle --release

echo -e "${BLUE}📱 Building Android APKs (split by ABI)...${NC}"
flutter build apk --release --split-per-abi

echo ""
echo -e "${GREEN}✅ Android builds complete!${NC}"
echo "  App Bundle: build/app/outputs/bundle/release/app-release.aab"
echo "  APKs: build/app/outputs/flutter-apk/"

# Check if on macOS for iOS build
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo "                     BUILDING iOS                            "
    echo "════════════════════════════════════════════════════════════"
    echo ""
    
    # Check for CocoaPods
    if ! command -v pod &> /dev/null; then
        echo -e "${RED}❌ CocoaPods not found!${NC}"
        echo "Install with: sudo gem install cocoapods"
        exit 1
    fi
    
    echo -e "${YELLOW}📦 Installing iOS pods...${NC}"
    cd ios
    pod install
    cd ..
    
    echo -e "${BLUE}📱 Building iOS IPA...${NC}"
    flutter build ipa --release
    
    echo ""
    echo -e "${GREEN}✅ iOS build complete!${NC}"
    echo "  IPA: build/ios/ipa/underground_toronto.ipa"
else
    echo ""
    echo -e "${YELLOW}ℹ️  Skipping iOS build (requires macOS)${NC}"
fi

echo ""
echo "════════════════════════════════════════════════════════════"
echo "                    BUILD COMPLETE! 🎉                       "
echo "════════════════════════════════════════════════════════════"
echo ""
echo -e "${GREEN}All builds completed successfully!${NC}"
echo ""
echo "📦 Output files:"
echo "  Android Bundle: build/app/outputs/bundle/release/app-release.aab"
echo "  Android APKs:   build/app/outputs/flutter-apk/"
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "  iOS IPA:        build/ios/ipa/underground_toronto.ipa"
fi
echo ""
echo "🎯 Next steps:"
echo "  1. Test release builds on real devices"
echo "  2. Upload to Play Console (Android) or App Store Connect (iOS)"
echo "  3. Complete store listings"
echo "  4. Submit for review!"
echo ""
echo "📚 See DEPLOYMENT.md for detailed submission instructions"
echo ""
echo -e "${GREEN}Happy publishing! 🚀${NC}"
