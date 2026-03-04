# CineSaver Setup Guide

## For Users (Installing the DMG)

### Quick Install (5 minutes)

1. **Download** `CineSaver-1.0.dmg` from the releases page
2. **Open** the DMG file (double-click it)
3. **Drag** CineSaverHost.app to the Applications folder symlink
4. **Double-click** CineSaver.saver to install (or manually copy to `~/Library/Screen Savers/`)
5. **Open** System Settings → Screen Saver
6. **Select** CineSaver from the list
7. **Launch** CineSaverHost from your Applications folder
8. **Click** "Choose Video File" and select any video (MP4, MOV, etc.)
9. **Test** with the Preview button in System Settings!

**That's it!** No configuration needed.

---

## For Developers (Building from Source)

### 1. Install Prerequisites

**Xcode** (from Mac App Store):
1. Open Mac App Store
2. Search for "Xcode"
3. Install (requires ~10GB+ free space)
4. Open Xcode once to accept license

**XcodeGen** (for project generation):
```bash
brew install xcodegen
```

### 2. Clone and Build

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/CineSaver.git
cd CineSaver

# Generate Xcode project
xcodegen generate

# Option A: Build and install locally
./scripts/build-and-install.sh

# Option B: Create distributable DMG
./scripts/create-dmg.sh
```

### 3. Optional: Customize Bundle IDs

The project comes with generic bundle IDs (`io.github.cinesaver.*`) that work out of the box.

If you want to customize them for your own distribution:

**Edit [`project.yml`](project.yml):**
```yaml
# Change these two lines:
PRODUCT_BUNDLE_IDENTIFIER: io.yourname.videosaver.host  # Line ~20
PRODUCT_BUNDLE_IDENTIFIER: io.yourname.videosaver       # Line ~40
```

**Regenerate project:**
```bash
xcodegen generate
```

### 4. Test Your Build

1. Open System Settings → Screen Saver
2. Select CineSaver
3. Run CineSaverHost app
4. Choose a video file
5. Click Preview button in System Settings

---

## Troubleshooting

### Screensaver Shows "No video selected"

1. Run **CineSaverHost** app from Applications
2. Click "Choose Video File"
3. Select a video file (MP4, MOV, etc.)

### Can't Find CineSaver in System Settings

1. Check installation: `ls ~/Library/Screen\ Savers/`
2. Restart System Settings
3. Try logging out and back in

### Build Errors

```bash
# Clean and rebuild
rm -rf build/
./scripts/build-and-install.sh

# Ensure Xcode is selected
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

### Viewing Debug Logs

```bash
# Watch screensaver logs in real-time
log stream --predicate 'process == "legacyScreenSaver"' --level debug
```

---

## Advanced Configuration

### Changing Video Storage Location

The video is copied to `~/Movies/.CineSaver/selected-video.mov` by default.

To change this, edit [`CineSaverHost/Shared/SaverSettings.swift`](CineSaverHost/Shared/SaverSettings.swift):

```swift
static func sharedContainerURL() -> URL? {
    // Change this to your preferred location
    guard let moviesDir = FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask).first else {
        return nil
    }
    return moviesDir.appendingPathComponent(".CineSaver")
}
```

### Building for Distribution

To create a signed DMG for distribution:

1. Update bundle IDs in [`project.yml`](project.yml)
2. Configure code signing in Xcode
3. Run: `./scripts/create-dmg.sh`
4. The DMG will be created as `CineSaver-1.0.dmg`

---

## Uninstallation

```bash
# Remove screensaver
rm -rf ~/Library/Screen\ Savers/CineSaver.saver

# Remove app
rm -rf /Applications/CineSaverHost.app

# (Optional) Remove stored video
rm -rf ~/Movies/.CineSaver/
```

---

## Project Structure

```
📁 CineSaver/
├── 📄 project.yml                      # XcodeGen config
├── 📁 Config/
│   ├── CineSaver-Info.plist          # Screensaver metadata
│   ├── CineSaver.entitlements        # Screensaver permissions
│   ├── CineSaverHost-Info.plist      # App metadata
│   └── CineSaverHost.entitlements    # App permissions
├── 📁 CineSaver/
│   └── VideoScreenSaverView.swift     # Main screensaver logic
├── 📁 CineSaverHost/
│   ├── App/
│   │   ├── CineSaverHostApp.swift    # SwiftUI app entry point
│   │   └── ContentView.swift          # Video picker UI
│   └── Shared/
│       └── SaverSettings.swift        # Shared settings
└── 📁 scripts/
    ├── build-and-install.sh           # Build + install script
    ├── install-saver.sh               # Install .saver bundle
    └── create-dmg.sh                  # Create DMG
```

---

## FAQ

**Q: Why do I need both CineSaverHost and CineSaver?**  
A: CineSaver is the screensaver itself (runs in System Settings). CineSaverHost is a helper app to choose which video to play, since screensavers can't easily show file pickers.

**Q: Can I use multiple videos?**  
A: Not yet, but it's on the roadmap! Currently only one video at a time.

**Q: Does it work on Intel Macs?**  
A: Yes! The screensaver is universal and works on both Apple Silicon and Intel.

**Q: Why isn't there audio?**  
A: Screensavers traditionally don't play audio. The player is muted by default to keep it peaceful.

**Q: Can I deploy this to the App Store?**  
A: Screensaver plugins (.saver bundles) cannot be distributed through the Mac App Store. Use DMG distribution or Homebrew instead.

**Q: How do I share this with friends?**  
A: Run `./scripts/create-dmg.sh` to create a DMG file, then share that file. They can install it without needing Xcode!

---

## Contributing

Pull requests welcome! Please test on both Intel and Apple Silicon Macs if possible.

---

For quick commands, see [QUICK_REFERENCE.md](QUICK_REFERENCE.md).
