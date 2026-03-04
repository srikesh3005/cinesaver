#!/usr/bin/env bash
set -euo pipefail

echo "🎬 CineSaver - Quick DMG Creator"
echo "==================================="
echo ""

cd "$(dirname "$0")/.."
PROJECT_DIR="$(pwd)"

APP_NAME="CineSaver"
VERSION="1.0"
DMG_NAME="${APP_NAME}-${VERSION}"
BUILD_DIR="$PROJECT_DIR/build"
DMG_STAGING="$PROJECT_DIR/dmg_staging"
OUTPUT_DMG="$PROJECT_DIR/${DMG_NAME}.dmg"

# Clean
echo "🧹 Cleaning..."
rm -rf "$DMG_STAGING"
rm -f "$OUTPUT_DMG"

# Build CineSaver
echo "📦 Building CineSaver.saver..."
xcodebuild -project CineSaver.xcodeproj -scheme CineSaver -configuration Release \
    -derivedDataPath "$BUILD_DIR" clean build \
    CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO \
    > /dev/null 2>&1

# Build CineSaverHost  
echo "📦 Building CineSaverHost.app..."
xcodebuild -project CineSaver.xcodeproj -scheme CineSaverHost -configuration Release \
    -derivedDataPath "$BUILD_DIR" clean build \
    CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO \
    > /dev/null 2>&1

SAVER_PATH="$BUILD_DIR/Build/Products/Release/CineSaver.saver"
APP_PATH="$BUILD_DIR/Build/Products/Release/CineSaverHost.app"

if [ ! -d "$SAVER_PATH" ] || [ ! -d "$APP_PATH" ]; then
    echo "❌ Build failed"
    exit 1
fi

echo "✅ Build complete"
echo ""

# Create staging
echo "📁 Packaging..."
mkdir -p "$DMG_STAGING"
cp -R "$APP_PATH" "$DMG_STAGING/"
cp -R "$SAVER_PATH" "$DMG_STAGING/"
ln -s /Applications "$DMG_STAGING/Applications"

# Create README
cat > "$DMG_STAGING/README.txt" << 'EOF'
CineSaver - Custom Video Screensaver for macOS
================================================

INSTALLATION:
1. Drag CineSaverHost.app to Applications folder
2. Double-click CineSaver.saver (or drag to ~/Library/Screen Savers/)
3. Open System Settings → Screen Saver → Select "CineSaver"
4. Launch CineSaverHost from Applications
5. Click "Choose Video File" to select your video

Your video will play as a screensaver!

UNINSTALL:
- Delete CineSaverHost.app from Applications
- Delete ~/Library/Screen Savers/CineSaver.saver

EOF

# Create DMG
echo "🔨 Creating DMG..."
hdiutil create -volname "$APP_NAME" -srcfolder "$DMG_STAGING" \
    -ov -format UDZO "$OUTPUT_DMG" > /dev/null 2>&1

rm -rf "$DMG_STAGING"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ DMG created successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📦 $OUTPUT_DMG"
echo "📊 $(du -h "$OUTPUT_DMG" | awk '{print $1}')"
echo ""

open -R "$OUTPUT_DMG"
