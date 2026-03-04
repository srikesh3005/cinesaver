#!/usr/bin/env bash
set -euo pipefail

echo "🎬 CineSaver - Build & Install Script"
echo "======================================"

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: xcodebuild not found."
    echo "Please install Xcode from the Mac App Store and run:"
    echo "  sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer"
    exit 1
fi

# Navigate to project directory
cd "$(dirname "$0")/.."
PROJECT_DIR="$(pwd)"

echo "📦 Building CineSaver screensaver..."

# Build with xcodebuild
xcodebuild \
    -project CineSaver.xcodeproj \
    -scheme CineSaver \
    -configuration Release \
    -derivedDataPath "$PROJECT_DIR/build" \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    | grep -E "^\*\*|Build succeeded|error:" || true

# Check if build succeeded
SAVER_PATH="$PROJECT_DIR/build/Build/Products/Release/CineSaver.saver"

if [ ! -d "$SAVER_PATH" ]; then
    echo "❌ Build failed. Please open the project in Xcode and build manually."
    echo "   Open: CineSaver.xcodeproj"
    exit 1
fi

echo "✅ Build succeeded!"
echo ""
echo "📥 Installing screensaver..."

# Install using install-saver.sh
bash "$PROJECT_DIR/scripts/install-saver.sh" "$SAVER_PATH"

echo ""
echo "✅ Installation complete!"
echo ""
echo "🎯 Next steps:"
echo "   1. Open System Settings → Screen Saver"
echo "   2. Select 'CineSaver' from the list"
echo "   3. Run CineSaverHost app to choose your video"
echo "   4. Preview your screensaver!"
echo ""
