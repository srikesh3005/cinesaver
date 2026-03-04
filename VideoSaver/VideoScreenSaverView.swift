import ScreenSaver
import AppKit
import AVFoundation

final class VideoScreenSaverView: ScreenSaverView {
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var observer: NSObjectProtocol?
    private var messageLayer: CATextLayer?
    private var fileMonitorTimer: Timer?
    private var lastFileModificationDate: Date?
    private var currentVideoURL: URL?

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        animationTimeInterval = 1.0 / 30.0
        wantsLayer = true
        setUpPlayer()
        startFileMonitoring()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        animationTimeInterval = 1.0 / 30.0
        wantsLayer = true
        setUpPlayer()
        startFileMonitoring()
    }

    deinit {
        stopFileMonitoring()
        cleanupPlayer()
    }
    
    override func viewWillMove(toWindow newWindow: NSWindow?) {
        super.viewWillMove(toWindow: newWindow)
        if newWindow == nil {
            // View is being removed from window - stop everything
            stopFileMonitoring()
            cleanupPlayer()
        } else {
            // View is being added to window - start monitoring
            startFileMonitoring()
        }
    }
    
    private func startFileMonitoring() {
        // Check for file changes every 2 seconds
        fileMonitorTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.checkForVideoFileChanges()
        }
    }
    
    private func stopFileMonitoring() {
        fileMonitorTimer?.invalidate()
        fileMonitorTimer = nil
    }
    
    private func checkForVideoFileChanges() {
        guard let videoURL = SaverSettings.selectedVideoURL() else { return }
        
        // Check if the file exists
        guard FileManager.default.fileExists(atPath: videoURL.path) else {
            // File was deleted
            if currentVideoURL != nil {
                cleanupPlayer()
                currentVideoURL = nil
                lastFileModificationDate = nil
                showMessage("Video file was removed.\n\nRun CineSaverHost to select a new video.")
            }
            return
        }
        
        // Get modification date
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: videoURL.path),
              let modDate = attributes[.modificationDate] as? Date else {
            return
        }
        
        // Check if file was modified or if we're loading for first time
        if lastFileModificationDate == nil || modDate > lastFileModificationDate! {
            lastFileModificationDate = modDate
            
            // If we already have a player and the file changed, reload
            if currentVideoURL != nil && player != nil {
                print("CineSaver: Video file changed, reloading...")
                cleanupPlayer()
                setUpPlayer()
            }
        }
    }
    
    private func cleanupPlayer() {
        player?.pause()
        player?.rate = 0
        playerLayer?.removeFromSuperlayer()
        player?.replaceCurrentItem(with: nil)
        player = nil
        playerLayer = nil
        messageLayer?.removeFromSuperlayer()
        messageLayer = nil
        if let observer {
            NotificationCenter.default.removeObserver(observer)
            self.observer = nil
        }
    }

    override func startAnimation() {
        super.startAnimation()
        if player == nil {
            setUpPlayer()
        }
        player?.play()
    }

    override func stopAnimation() {
        cleanupPlayer()
        super.stopAnimation()
    }

    override func animateOneFrame() {
        // AVPlayer drives rendering.
    }

    override func layout() {
        super.layout()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        playerLayer?.frame = bounds
        messageLayer?.frame = bounds
        CATransaction.commit()
    }

    private func setUpPlayer() {
        guard let videoURL = SaverSettings.selectedVideoURL() else {
            showMessage("Storage path unavailable.\n\nPath: \(SaverSettings.sharedContainerURL()?.path ?? "nil")")
            return
        }
        
        guard FileManager.default.fileExists(atPath: videoURL.path) else {
            showMessage("No video selected.\n\nRun CineSaverHost app to choose a video.\n\nExpected path:\n\(videoURL.path)")
            return
        }
        
        // Check if file is readable
        guard FileManager.default.isReadableFile(atPath: videoURL.path) else {
            showMessage("Video file is not readable.\n\nPath: \(videoURL.path)\n\nCheck file permissions.")
            return
        }
        
        // Store current video URL and modification date
        currentVideoURL = videoURL
        if let attributes = try? FileManager.default.attributesOfItem(atPath: videoURL.path),
           let modDate = attributes[.modificationDate] as? Date {
            lastFileModificationDate = modDate
        }

        let item = AVPlayerItem(url: videoURL)
        let newPlayer = AVPlayer(playerItem: item)
        
        // Observe player status
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemFailedToPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] notification in
            if let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error {
                self?.showMessage("Video playback error:\n\n\(error.localizedDescription)\n\nTry selecting a different video (MP4/H.264).")
            }
        }
        
        newPlayer.actionAtItemEnd = .none
        newPlayer.isMuted = true  // No audio support
        newPlayer.volume = 0

        let newLayer = AVPlayerLayer(player: newPlayer)
        newLayer.videoGravity = .resizeAspectFill  // Fill screen by cropping, maintain aspect ratio
        newLayer.frame = bounds
        newLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        newLayer.needsDisplayOnBoundsChange = true
        newLayer.backgroundColor = NSColor.black.cgColor

        layer?.addSublayer(newLayer)

        observer = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { _ in
            newPlayer.seek(to: .zero)
            newPlayer.play()
        }

        player = newPlayer
        playerLayer = newLayer
        
        // Auto-play if animation is running
        if isAnimating {
            newPlayer.play()
        }
        
        // Wait a bit then check if video loaded successfully
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self, weak newPlayer] in
            guard let player = newPlayer else { return }
            if player.currentItem?.status == .failed {
                if let error = player.currentItem?.error {
                    self?.showMessage("Failed to load video:\n\n\(error.localizedDescription)\n\nCodec may not be supported.\nTry H.264/MP4 format.")
                } else {
                    self?.showMessage("Failed to load video.\n\nCodec may not be supported.\nTry H.264/MP4 format.")
                }
            }
        }
    }
    
    private func showMessage(_ text: String) {
        let textLayer = CATextLayer()
        textLayer.string = text
        textLayer.fontSize = 24
        textLayer.foregroundColor = NSColor.white.cgColor
        textLayer.backgroundColor = NSColor.black.cgColor
        textLayer.alignmentMode = .center
        textLayer.frame = bounds
        textLayer.contentsScale = 2.0
        textLayer.isWrapped = true
        
        layer?.addSublayer(textLayer)
        messageLayer = textLayer
    }
}
