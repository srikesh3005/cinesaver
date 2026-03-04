import ScreenSaver
import AppKit
import AVFoundation

final class VideoScreenSaverView: ScreenSaverView {
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var observer: NSObjectProtocol?
    private var messageLayer: CATextLayer?

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        animationTimeInterval = 1.0 / 30.0
        wantsLayer = true
        setUpPlayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        animationTimeInterval = 1.0 / 30.0
        wantsLayer = true
        setUpPlayer()
    }

    deinit {
        cleanupPlayer()
    }
    
    override func viewWillMove(toWindow newWindow: NSWindow?) {
        super.viewWillMove(toWindow: newWindow)
        if newWindow == nil {
            // View is being removed from window - stop everything
            cleanupPlayer()
        }
    }
    
    private func cleanupPlayer() {
        player?.pause()
        player?.rate = 0
        playerLayer?.removeFromSuperlayer()
        player?.replaceCurrentItem(with: nil)
        player = nil
        playerLayer = nil
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
        
        // Wait a bit then check if video loaded successfully (but don't auto-play)
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
