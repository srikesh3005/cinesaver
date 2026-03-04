#!/usr/bin/env bash
set -euo pipefail

echo "🎬 CineSaver - DMG Creator"
echo "============================"
echo ""

# Navigate to project directory
cd "$(dirname "$0")/.."
PROJECT_DIR="$(pwd)"

# Configuration
APP_NAME="CineSaver"
VERSION="1.0"
DMG_NAME="${APP_NAME}-${VERSION}"
BUILD_DIR="$PROJECT_DIR/build"
DMG_STAGING="$PROJECT_DIR/dmg_staging"
OUTPUT_DMG="$PROJECT_DIR/${DMG_NAME}.dmg"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf "$DMG_STAGING"
rm -f "$OUTPUT_DMG"
rm -f "${OUTPUT_DMG}.temp.dmg"

# Build CineSaver (.saver bundle)
echo ""
echo "📦 Building CineSaver screensaver..."
xcodebuild \
    -project CineSaver.xcodeproj \
    -scheme CineSaver \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR" \
    clean build \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    | grep -E "^\*\*|Build succeeded|error:" || true

# Build CineSaverHost (app)
echo ""
echo "📦 Building CineSaverHost app..."
xcodebuild \
    -project CineSaver.xcodeproj \
    -scheme CineSaverHost \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR" \
    clean build \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    | grep -E "^\*\*|Build succeeded|error:" || true

# Check if builds succeeded
SAVER_PATH="$BUILD_DIR/Build/Products/Release/CineSaver.saver"
APP_PATH="$BUILD_DIR/Build/Products/Release/CineSaverHost.app"

if [ ! -d "$SAVER_PATH" ]; then
    echo "❌ CineSaver.saver build failed"
    exit 1
fi

if [ ! -d "$APP_PATH" ]; then
    echo "❌ CineSaverHost.app build failed"
    exit 1
fi

echo "✅ Both builds succeeded!"
echo ""

# Create staging directory
echo "📁 Creating DMG staging directory..."
mkdir -p "$DMG_STAGING"

# Copy applications
echo "📋 Copying applications..."
cp -R "$APP_PATH" "$DMG_STAGING/"
cp -R "$SAVER_PATH" "$DMG_STAGING/"

# Create installation instructions
echo "📝 Creating installation guide..."
cat > "$DMG_STAGING/Installation Instructions.txt" << 'EOF'
╔═══════════════════════════════════════════════════╗
║         CineSaver Installation Guide             ║
╚═══════════════════════════════════════════════════╝

🎬 Thank you for downloading CineSaver!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

QUICK INSTALL (Recommended)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Copy CineSaverHost.app → Applications folder
   
2. Double-click CineSaver.saver to install
   (or copy it to ~/Library/Screen Savers/)

3. Open System Settings → Screen Saver

4. Select "CineSaver" from the list

5. Open CineSaverHost from Applications

6. Click "Choose Video File" and select your video

7. Done! Preview your screensaver!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

WHAT'S INCLUDED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📱 CineSaverHost.app
   → The configuration app for choosing your video
   → Drag to /Applications folder

🖥️  CineSaver.saver
   → The actual screensaver bundle
   → Double-click to install automatically

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MANUAL INSTALLATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

If double-clicking CineSaver.saver doesn't work:

1. Open Finder
2. Press Cmd+Shift+G
3. Type: ~/Library/Screen Savers/
4. Copy CineSaver.saver to that folder
5. Restart System Settings if needed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

TROUBLESHOOTING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

❓ Screensaver shows blank/black screen
   → Open CineSaverHost and select a video first
   → Make sure the video file still exists

❓ "No video selected" message appears
   → Run CineSaverHost.app
   → Click "Choose Video File"
   → Select any MP4, MOV, or video file

❓ Can't find the screensaver in System Settings
   → Check if CineSaver.saver is in ~/Library/Screen Savers/
   → Restart System Settings
   → Try logging out and back in

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

UNINSTALL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Delete CineSaverHost.app from Applications
2. Delete ~/Library/Screen Savers/CineSaver.saver
3. (Optional) Delete ~/Movies/.CineSaver/

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Need help? Check the README or source code on GitHub!

EOF

# Create a symbolic link to Applications folder for convenience
echo "🔗 Creating Applications symlink..."
ln -s /Applications "$DMG_STAGING/Applications"

# Create README
echo "📄 Creating README..."
cat > "$DMG_STAGING/README.txt" << 'EOF'
CineSaver v1.0
===============

A modern screensaver for macOS that lets you use any video file.

Features:
• Clean, modern SwiftUI interface
• Support for any video format (MP4, MOV, etc.)
• Seamless looping playback
• Native Apple Silicon performance
• Simple setup

See "Installation Instructions.txt" for setup guide.

EOF

# Calculate optimal DMG size
echo ""
echo "📏 Calculating DMG size..."
SIZE=$(du -sm "$DMG_STAGING" | awk '{print $1}')
SIZE=$((SIZE + 50))  # Add 50MB padding

# Create temporary DMG
echo "🔨 Creating temporary DMG..."
hdiutil create \
    -srcfolder "$DMG_STAGING" \
    -volname "$APP_NAME" \
    -fs HFS+ \
    -fsargs "-c c=64,a=16,e=16" \
    -format UDRW \
    -size ${SIZE}m \
    "${OUTPUT_DMG}.temp.dmg"

# Mount the temporary DMG
echo "📂 Mounting temporary DMG..."
MOUNT_DIR=$(hdiutil attach -readwrite -noverify -noautoopen "${OUTPUT_DMG}.temp.dmg" | grep -E "^/dev/" | tail -1 | awk '{print $3}')

if [ -z "$MOUNT_DIR" ]; then
    echo "❌ Failed to mount DMG"
    exit 1
fi

echo "   Mounted at: $MOUNT_DIR"

# Set custom icon positions and window properties
echo "🎨 Configuring DMG appearance..."

# Wait for mount to be ready
sleep 2

# Set the icon positions using AppleScript (skip background for compatibility)
osascript << EOD
tell application "Finder"
    tell disk "$APP_NAME"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {100, 100, 800, 500}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 100
        try
            set position of item "CineSaverHost.app" of container window to {150, 150}
            set position of item "CineSaver.saver" of container window to {150, 280}
            set position of item "Applications" of container window to {500, 150}
            set position of item "Installation Instructions.txt" of container window to {500, 280}
        end try
        update without registering applications
        delay 2
    end tell
end tell
EOD

# Wait for Finder to apply changes
sleep 2

# Unmount
echo "💾 Finalizing DMG..."
hdiutil detach "$MOUNT_DIR" -quiet -force || true
sleep 2

# Convert to compressed, read-only DMG
echo "🗜️  Compressing DMG..."
hdiutil convert "${OUTPUT_DMG}.temp.dmg" \
    -format UDZO \
    -imagekey zlib-level=9 \
    -o "$OUTPUT_DMG"

# Clean up
echo "🧹 Cleaning up..."
rm -f "${OUTPUT_DMG}.temp.dmg"
rm -rf "$DMG_STAGING"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ DMG created successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📦 Location: $OUTPUT_DMG"
echo "📊 Size: $(du -h "$OUTPUT_DMG" | awk '{print $1}')"
echo ""
echo "🎯 Ready to distribute!"
echo ""

# Reveal in Finder
open -R "$OUTPUT_DMG"
