#!/bin/bash

# iOS Release Build Script
# This script builds a release version of the iOS app

set -e  # Exit on error

echo "🚀 Building Underground Toronto Navigator - iOS Release"
echo "========================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ Error: iOS builds require macOS${NC}"
    exit 1
fi

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ Error: Xcode not found${NC}"
    echo "Install Xcode from the Mac App Store"
    exit 1
fi

echo -e "${GREEN}✓ macOS and Xcode detected${NC}"

# Check for CocoaPods
if ! command -v pod &> /dev/null; then
    echo -e "${RED}❌ Error: CocoaPods not found${NC}"
    echo "Install with: sudo gem install cocoapods"
    exit 1
fi

echo -e "${GREEN}✓ CocoaPods detected${NC}"

# Clean previous builds
echo ""
echo "🧹 Cleaning previous builds..."
flutter clean
cd ios
rm -rf Pods
rm -rf .symlinks
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec
cd ..

# Get dependencies
echo ""
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Install iOS pods
echo ""
echo "📦 Installing iOS pods..."
cd ios
pod install
cd ..

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

# Build IPA
echo ""
echo "📱 Building iOS release (IPA)..."
flutter build ipa --release

# Display results
echo ""
echo "========================================================"
echo -e "${GREEN}✅ Build completed successfully!${NC}"
echo ""
echo "📦 Output file:"
echo "  IPA: build/ios/ipa/underground_toronto.ipa"
echo ""

# Get file size
if [ -f "build/ios/ipa/underground_toronto.ipa" ]; then
    IPA_SIZE=$(du -h build/ios/ipa/underground_toronto.ipa | cut -f1)
    echo "📊 File size: $IPA_SIZE"
else
    echo -e "${YELLOW}⚠️  IPA file not found at expected location${NC}"
    echo "Check build/ios/ipa/ directory"
fi

echo ""
echo "🎯 Next steps:"
echo "  Option 1 - Using Transporter:"
echo "    1. Download Transporter app from Mac App Store"
echo "    2. Open underground_toronto.ipa in Transporter"
echo "    3. Click 'Deliver' to upload to App Store Connect"
echo ""
echo "  Option 2 - Using Xcode:"
echo "    1. Open ios/Runner.xcworkspace in Xcode"
echo "    2. Select 'Any iOS Device' as destination"
echo "    3. Product → Archive"
echo "    4. Distribute App → App Store Connect"
echo ""
echo "  Then:"
echo "    5. Go to App Store Connect"
echo "    6. Fill in app information and screenshots"
echo "    7. Submit for review"
echo ""
echo -e "${GREEN}Happy publishing! 🚀${NC}"
