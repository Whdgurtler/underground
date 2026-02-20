# App Icons Guide

## Required Icon Sizes

### Android
All Android icons are automatically generated from a single 1024x1024 source image using Flutter's icon generation tools.

**Required sizes:**
- mipmap-mdpi: 48x48
- mipmap-hdpi: 72x72
- mipmap-xhdpi: 96x96
- mipmap-xxhdpi: 144x144
- mipmap-xxxhdpi: 192x192

**Play Store:**
- 512x512 PNG (uploaded to Play Console)

### iOS
All iOS icons are also generated from the 1024x1024 source.

**Required sizes (in Info.plist):**
- 20x20 (iPhone Notification)
- 29x29 (iPhone Settings)
- 40x40 (iPhone Spotlight)
- 60x60 (iPhone App)
- 76x76 (iPad App)
- 83.5x83.5 (iPad Pro)
- 1024x1024 (App Store)

## How to Generate Icons

### Step 1: Create Your Master Icon (1024x1024)

Design guidelines:
- **Size:** 1024x1024 pixels
- **Format:** PNG with transparency (iOS), PNG/JPEG (Android)
- **Style:** Simple, recognizable, works at small sizes
- **Content:** No text (or minimal text)
- **Safe area:** Keep important content within 900x900 center

**Design ideas for Underground Toronto:**
- 🗺️ Map with underground tunnel icon
- 📍 Location pin with Toronto CN Tower
- 🚇 Subway/tunnel entrance
- 📱 Phone with map overlay
- 🧭 Compass with "PATH" text

**Colors:**
- Primary: Toronto blue (#004C97)
- Accent: Toronto red (#DA291C)
- Background: White or gradient

### Step 2: Add flutter_launcher_icons Package

Add to pubspec.yaml:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
```

### Step 3: Create Icon Files

```
assets/
  icon/
    app_icon.png          (1024x1024 - main icon)
    app_icon_foreground.png  (1024x1024 - adaptive Android)
```

### Step 4: Generate Icons

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

This automatically creates all required sizes!

## Free Icon Design Tools

### Online Tools
1. **Canva** (https://canva.com)
   - Free templates
   - Easy to use
   - Export as PNG

2. **Figma** (https://figma.com)
   - Professional design tool
   - Free tier
   - Great for icons

3. **AppIcon.co** (https://appicon.co)
   - Upload 1024x1024 image
   - Generates all sizes
   - Free!

### Desktop Tools
1. **GIMP** (Free, open source)
   - Full Photoshop alternative
   - https://gimp.org

2. **Inkscape** (Free, vector graphics)
   - Great for logos
   - https://inkscape.org

3. **Krita** (Free, painting)
   - Digital art tool
   - https://krita.org

## Quick Icon Template

Here's a simple design you can create in Canva:

1. Create 1024x1024 canvas
2. Background: White or blue gradient
3. Add map icon (from Canva library)
4. Add location pin overlay
5. Add text "UT" or "PATH" (optional)
6. Export as PNG

## Icon Checklist

- [ ] Created 1024x1024 master icon
- [ ] Icon looks good at small sizes (60x60)
- [ ] No transparency issues
- [ ] Follows platform guidelines
- [ ] Tested on light and dark backgrounds
- [ ] Generated Android icons
- [ ] Generated iOS icons
- [ ] Uploaded to App Store Connect (1024x1024)
- [ ] Uploaded to Play Console (512x512)

## Store Screenshots

You also need screenshots for the stores:

### Android Screenshots
- **Minimum:** 2 screenshots
- **Recommended:** 4-8 screenshots
- **Size:** 1080x1920 or 1920x1080
- **Format:** PNG or JPEG

### iOS Screenshots
- **iPhone 6.7":** 1290x2796 (required, 3 screenshots)
- **iPhone 6.5":** 1242x2688 (required, 3 screenshots)
- **iPad Pro 12.9":** 2048x2732 (optional)

### What to Screenshot
1. Main map view with GPS active
2. Underground mode with orange markers
3. Info panel showing detailed data
4. Path tracking visualization
5. Permission prompt (if attractive)

### Screenshot Tips
- Use physical devices for best quality
- Add text overlays explaining features
- Use screenshot framing tools (screenshot.rocks)
- Show the app in action, not empty screens
- Highlight the unique underground feature

## Feature Graphic (Android)

**Size:** 1024x500 pixels
**Format:** PNG or JPEG
**Purpose:** Shown at top of Play Store listing

Design should include:
- App name
- Key visual/icon
- Brief tagline
- Eye-catching colors

Example layout:
```
[App Icon] | UNDERGROUND TORONTO
           | Navigate the PATH System
           | GPS + Accelerometer Tracking
```

## Example Icon Code

Save this as SVG and convert to PNG:

```svg
<svg width="1024" height="1024" xmlns="http://www.w3.org/2000/svg">
  <!-- Background -->
  <rect width="1024" height="1024" fill="#004C97"/>
  
  <!-- Map grid -->
  <g stroke="#FFFFFF" stroke-width="2" opacity="0.3">
    <line x1="0" y1="256" x2="1024" y2="256"/>
    <line x1="0" y1="512" x2="1024" y2="512"/>
    <line x1="0" y1="768" x2="1024" y2="768"/>
    <line x1="256" y1="0" x2="256" y2="1024"/>
    <line x1="512" y1="0" x2="512" y2="1024"/>
    <line x1="768" y1="0" x2="768" y2="1024"/>
  </g>
  
  <!-- Location pin -->
  <circle cx="512" cy="462" r="150" fill="#DA291C"/>
  <circle cx="512" cy="462" r="50" fill="#FFFFFF"/>
  <path d="M 512 612 L 562 862 L 512 812 L 462 862 Z" fill="#DA291C"/>
  
  <!-- Optional: "UT" text -->
  <text x="512" y="520" font-size="120" font-weight="bold" 
        text-anchor="middle" fill="#FFFFFF">UT</text>
</svg>
```

## Resources

- [Android Icon Guidelines](https://developer.android.com/google-play/resources/icon-design-specifications)
- [iOS Icon Guidelines](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [Material Design Icons](https://fonts.google.com/icons)
- [Flutter Icon Tutorial](https://pub.dev/packages/flutter_launcher_icons)

## Need Help?

If you need a professional designer:
- **Fiverr:** $20-50 for simple icon
- **99designs:** $199+ for full package
- **Upwork:** Varies by designer

Or use the free tools above - you can create a great icon yourself! 🎨
