# Release Notes - CineSaver v1.0

## 🎬 First Release

A modern macOS screensaver that lets you use any video file as your screensaver.

### Features

- ✨ **Simple Setup** - Just install the DMG and choose a video
- 🎥 **Any Video Format** - Supports MP4, MOV, and any AVFoundation-compatible format
- 🔄 **Seamless Looping** - Videos loop automatically without gaps
- ⚡ **Native Performance** - Built with Swift, optimized for Apple Silicon & Intel
- 🎯 **No Configuration** - Works out of the box with sensible defaults
- 🔇 **Silent** - Audio is muted by default (as screensavers should be)

### What's Included

- **CineSaver.saver** - The screensaver plugin
- **CineSaverHost.app** - Configuration app for choosing videos
- **Installation Guide** - Step-by-step instructions

### System Requirements

- macOS 13.0 (Ventura) or later
- Works on both Apple Silicon and Intel Macs

### Installation

1. Download `CineSaver-1.0.dmg`
2. Open the DMG file
3. Drag CineSaverHost.app to Applications
4. Double-click CineSaver.saver to install
5. Open System Settings → Screen Saver → Select CineSaver
6. Run CineSaverHost and choose a video

See [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed instructions.

### Known Limitations

- Only one video at a time (playlist support planned for future)
- No audio playback (by design)
- No per-monitor video selection (yet)

### Technical Details

- **Built with**: Swift 5.9, SwiftUI, AVFoundation
- **Architecture**: Universal (Apple Silicon + Intel)
- **Code Signing**: Unsigned (you may see a security warning on first run)
- **Storage**: Videos copied to `~/Movies/.CineSaver/`

### Troubleshooting

If you see "CineSaver cannot be opened because it is from an unidentified developer":
1. Right-click CineSaver.saver
2. Select "Open"
3. Click "Open" in the security dialog

For other issues, see [SETUP_GUIDE.md](SETUP_GUIDE.md).

---

**Note**: This is open source software. Feel free to inspect the code, report issues, or contribute!
