# Quick Reference Card - CineSaver

## 🚀 Quick Commands

### First Time Setup
```bash
# 1. Generate project (if needed)
xcodegen generate

# 2. Build and install locally OR create DMG for distribution
./scripts/build-and-install.sh        # Local install
./scripts/create-dmg.sh                # Create distributable DMG
```

**That's it!** No configuration required - works out of the box.

### Regular Usage
```bash
# Create DMG for distribution
./scripts/create-dmg.sh

# Rebuild and reinstall locally
./scripts/build-and-install.sh

# Manual install (if you built in Xcode)
./scripts/install-saver.sh /path/to/CineSaver.saver

# Clean build
rm -rf build/ && ./scripts/build-and-install.sh

# Uninstall
rm -rf ~/Library/Screen\ Savers/CineSaver.saver
```

## 📁 Important Files

| File | Purpose |
|------|---------|
| `project.yml` | Xcode project configuration |
| `SaverSettings.swift` | Shared settings (App Group ID) |
| `VideoScreenSaverView.swift` | Screensaver logic |
| `ContentView.swift` | Video picker UI |
| `build-and-install.sh` | Build automation for local install |
| `create-dmg.sh` | Create distributable DMG file |

## 🔑 Key Configuration

**No configuration required!** Works out of the box with these bundle IDs:
- `io.github.cinesaver.host` (CineSaverHost app)
- `io.github.cinesaver` (CineSaver screensaver)

**Optional customization:**
You can change bundle IDs in `project.yml` if desired, then run `xcodegen generate`.

## 📍 System Locations

```bash
# Screensaver install location
~/Library/Screen Savers/CineSaver.saver

# Shared video location
~/Movies/.CineSaver/selected-video.mov

# Build output
build/Build/Products/Release/CineSaver.saver
```

## 🐛 Debugging

```bash
# View screensaver logs in real-time
log stream --predicate 'process == "legacyScreenSaver"' --level debug

# Check if screensaver is installed
ls -la ~/Library/Screen\ Savers/

# Check if video file exists
ls -la ~/Movies/.CineSaver/
```

## ⚙️ Common Tasks

### Change Video
1. Run CineSaverHost app
2. Click "Choose Video File"
3. Select new video

### Test Screensaver
1. System Settings → Screen Saver
2. Select CineSaver
3. Click "Preview" button

### Update Code
1. Edit files in Xcode
2. Run: `./scripts/build-and-install.sh`
3. Test with Preview button

### Share with Friends

**Easy way (DMG):**
1. Run: `./scripts/create-dmg.sh`
2. Share the `CineSaver-1.0.dmg` file
3. They mount the DMG and follow included instructions

**Manual way:**
1. Build in Release mode
2. Share `CineSaver.saver` and `CineSaverHost.app`
3. They run: `./scripts/install-saver.sh CineSaver.saver`
4. They use CineSaverHost to pick video

## 🎯 Supported Video Formats

- MP4 (`.mp4`, `.m4v`)
- MOV (`.mov`)
- QuickTime (`.qt`)
- Any format supported by AVFoundation

## 📋 Checklist for First Build

- [ ] Xcode installed from Mac App Store
- [ ] Run `xcodegen generate`
- [ ] Run `./scripts/build-and-install.sh` or `./scripts/create-dmg.sh`
- [ ] Open System Settings → Screen Saver
- [ ] Select CineSaver
- [ ] Run CineSaverHost app
- [ ] Choose a video
- [ ] Test with Preview button

---

**Quick Help:** See [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed instructions.
