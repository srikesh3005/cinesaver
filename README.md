<p align="center">
  <img src="assets/logo.png" alt="CineSaver Logo" width="300"/>
</p>

<h1 align="center">CineSaver</h1>

<p align="center">
  <strong>A modern, minimal custom-video screensaver for macOS</strong><br>
  Apple Silicon & Intel
</p>

<p align="center">
  <a href="https://github.com/srikesh3005/cinesaver/releases"><img src="https://img.shields.io/github/v/release/srikesh3005/cinesaver?style=flat-square" alt="Release"></a>
  <a href="https://github.com/srikesh3005/cinesaver/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square" alt="License"></a>
  <img src="https://img.shields.io/badge/macOS-13.0+-blue?style=flat-square" alt="macOS">
  <img src="https://img.shields.io/badge/Swift-5.9-orange?style=flat-square" alt="Swift">
</p>

---

## Overview

CineSaver lets you use **any local video** as your macOS screensaver. Unlike the aging Aerial screensaver with its bugs and outdated UI, CineSaver provides:

- ✨ Clean, modern SwiftUI interface
- 🎥 Support for any video format (MP4, MOV, etc.)
- 🔄 Seamless looping
- ⚡ Native Apple Silicon performance
- 🎯 Simple setup - no complex configuration

## What's Included

- **CineSaverHost** - SwiftUI app to select your video
- **CineSaver.saver** - The actual screensaver bundle
- **Shared Storage** - Simple file storage in `~/Movies/.CineSaver/`

## Quick Start

### For Users (Easy Install)

1. **Download** the latest `CineSaver-1.0.dmg` from releases
2. **Open** the DMG file
3. **Copy** CineSaverHost.app to Applications
4. **Double-click** CineSaver.saver to install (or copy to `~/Library/Screen Savers/`)
5. **Open** System Settings → Screen Saver → Select CineSaver
6. **Run** CineSaverHost from Applications and choose a video
7. **Enjoy!** Test with the Preview button

### For Developers

#### Option 1: Create Distributable DMG (Recommended)

```bash
# Generate Xcode project
xcodegen generate

# Build and create a DMG file
./scripts/create-dmg.sh
```

This creates `CineSaver-1.0.dmg` ready for distribution!

#### Option 2: Build & Install Locally

```bash
# Build and install in one step
./scripts/build-and-install.sh
```

#### Option 3: Manual Build in Xcode

1. Open `CineSaver.xcodeproj` in Xcode
2. Select **CineSaver** scheme
3. Build (⌘+B)
4. In Xcode, right-click the **CineSaver.saver** product → Show in Finder
5. Install:
   ```bash
   ./scripts/install-saver.sh /path/to/CineSaver.saver
   ```

### Configuration (Optional)

**No configuration required!** The project works out of the box with generic bundle IDs.

If you want to customize the bundle IDs for your own distribution:

**Update Bundle IDs in [`project.yml`](project.yml):**
```yaml
PRODUCT_BUNDLE_IDENTIFIER: io.yourname.videosaver.host  # Line ~20
PRODUCT_BUNDLE_IDENTIFIER: io.yourname.videosaver       # Line ~40
```

**Re-generate project after changes:**
```bash
xcodegen generate
```

### Usage

1. **Install Screensaver**
   - Open System Settings
   - Navigate to Screen Saver
   - Select **CineSaver** from the list

2. **Choose Your Video**
   - Run the **CineSaverHost** app
   - Click **"Choose Video File"**
   - Select any video from your Mac
   
3. **Test It!**
   - Preview in System Settings
   - Or wait for your screensaver timer

## Technical Details

### Architecture

- **Screensaver Framework**: Uses `ScreenSaver.framework` for native integration
- **Video Playback**: `AVFoundation` with `AVPlayerLayer` (hardware accelerated)
- **Storage**: Simple file-based approach using `~/Movies/.CineSaver/`
- **No Sandbox**: Disabled for screensaver compatibility
- **Audio**: Muted by default (screensavers typically don't play audio)
- **Looping**: Videos loop automatically and seamlessly

### File Structure

```
CineSaver/
├── project.yml                    # XcodeGen configuration
├── Config/
│   ├── CineSaver-Info.plist     # Screensaver bundle info
│   ├── CineSaver.entitlements   # Screensaver entitlements
│   └── CineSaverHost.entitlements
├── CineSaver/
│   └── VideoScreenSaverView.swift # Main screensaver logic
├── CineSaverHost/
│   ├── App/
│   │   ├── CineSaverHostApp.swift
│   │   └── ContentView.swift      # Video selection UI
│   └── Shared/
│       └── SaverSettings.swift    # Shared configuration
└── scripts/
    ├── install-saver.sh           # Manual installation
    └── build-and-install.sh       # Automated build + install
```

## Troubleshooting

### Screensaver Shows "No video selected" Message

- Run **CineSaverHost** app from Applications
- Click "Choose Video File" and select a video
- Make sure the video file still exists in its original location

### Screensaver Shows Blank/Black Screen

- Wait a few seconds for the video to load
- Try selecting a different video (H.264/MP4 recommended)
- Check that the video file is readable and not corrupted

### Can't Find CineSaver in System Settings

- Make sure CineSaver.saver is in `~/Library/Screen Savers/`
- Restart System Settings
- Try logging out and back in

### Build Errors

- Install full Xcode (not just Command Line Tools)
- Run: `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`
- Clean build folder: `rm -rf build/`
- Regenerate project: `xcodegen generate`

## Future Enhancements

- 📁 Multiple video playlists
- 🎨 Custom transition effects
- 🖥️ Per-display video assignment  
- ⚙️ Playback speed controls
- 🔊 Optional audio support
- 🌓 Time-based video selection

## License

MIT License - Feel free to use and modify!

## Credits

Built as a modern alternative to Aerial screensaver for macOS Apple Silicon.

- Settings UI inside the screensaver panel.
