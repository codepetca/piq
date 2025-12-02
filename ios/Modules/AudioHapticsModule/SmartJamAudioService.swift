import AVFoundation
import Observation

/// Service for looping SmartJam backing tracks. Safe to call even when assets are missing.
@Observable
final class SmartJamAudioService {
    private(set) var isPlaying: Bool = false
    private var player: AVAudioPlayer?
    private var currentConfig: SmartJamConfig?

    func startJam(for config: SmartJamConfig) {
        if currentConfig != config {
            player = loadPlayer(for: config)
            currentConfig = config
        }

        guard let player = player else { return }

        configureSession()
        if let targetBPM = config.targetBPM {
            let rate = playbackRate(for: targetBPM, baseBPM: config.baseBPM)
            player.enableRate = true
            player.rate = rate
        } else {
            player.enableRate = true
            player.rate = 1.0
        }

        player.numberOfLoops = -1
        player.play()
        isPlaying = true
    }

    func pauseJam() {
        guard isPlaying else { return }
        player?.pause()
        isPlaying = false
    }

    func resumeJam() {
        guard !isPlaying, let player else { return }
        player.play()
        isPlaying = true
    }

    func stopJam() {
        player?.stop()
        player = nil
        currentConfig = nil
        isPlaying = false
    }

    // MARK: - Private

    private func loadPlayer(for config: SmartJamConfig) -> AVAudioPlayer? {
        // Support names with or without extension. If missing, we silently skip playback.
        let assetName = config.assetName as NSString
        let name = assetName.deletingPathExtension
        let ext = assetName.pathExtension
        let extArgument: String? = ext.isEmpty ? nil : ext

        guard let url = Bundle.main.url(forResource: name, withExtension: extArgument) else {
            print("SmartJamAudioService: missing asset \(config.assetName)")
            return nil
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            return player
        } catch {
            print("SmartJamAudioService: failed to load asset \(config.assetName): \(error)")
            return nil
        }
    }

    private func configureSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("SmartJamAudioService: failed to configure audio session: \(error)")
        }
    }

    private func playbackRate(for targetBPM: Int, baseBPM: Int) -> Float {
        guard baseBPM > 0 else { return 1.0 }
        let ratio = Float(targetBPM) / Float(baseBPM)
        // Keep within reasonable range to avoid artifacts.
        return max(0.75, min(1.25, ratio))
    }
}
