import AVFoundation
import Observation

/// Service for metronome click generation using AVAudioEngine.
@Observable
final class MetronomeService {

    // MARK: - Public Properties

    private(set) var isPlaying: Bool = false
    var bpm: Int = 120 {
        didSet {
            if isPlaying {
                // Restart with new BPM
                stop()
                start()
            }
        }
    }

    // MARK: - Private Properties

    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var clickBuffer: AVAudioPCMBuffer?
    private var timer: Timer?

    // MARK: - Initialization

    init() {
        setupAudio()
    }

    deinit {
        stop()
    }

    // MARK: - Public Methods

    /// Start the metronome at the current BPM.
    func start() {
        guard !isPlaying else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
            return
        }

        guard let engine = audioEngine, let _ = playerNode else {
            setupAudio()
            guard audioEngine != nil, playerNode != nil else { return }
            start()
            return
        }

        do {
            try engine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
            return
        }

        isPlaying = true
        scheduleClicks()
    }

    /// Stop the metronome.
    func stop() {
        timer?.invalidate()
        timer = nil

        playerNode?.stop()
        audioEngine?.stop()

        isPlaying = false
    }

    /// Set the BPM (beats per minute). Range: 40-240.
    func setBPM(_ newBPM: Int) {
        bpm = max(40, min(240, newBPM))
    }

    /// Increase BPM by 5.
    func increaseBPM() {
        setBPM(bpm + 5)
    }

    /// Decrease BPM by 5.
    func decreaseBPM() {
        setBPM(bpm - 5)
    }

    // MARK: - Private Methods

    private func setupAudio() {
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()

        guard let engine = audioEngine, let player = playerNode else { return }

        engine.attach(player)

        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        engine.connect(player, to: engine.mainMixerNode, format: format)

        // Generate click sound buffer
        clickBuffer = generateClickBuffer(format: format)
    }

    private func generateClickBuffer(format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let sampleRate = format.sampleRate
        let duration = 0.05 // 50ms click
        let frameCount = AVAudioFrameCount(sampleRate * duration)

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return nil
        }

        buffer.frameLength = frameCount

        guard let channelData = buffer.floatChannelData?[0] else {
            return nil
        }

        // Generate a short click sound (sine wave with envelope)
        let frequency: Float = 880.0 // A5 note
        let amplitude: Float = 0.5

        for frame in 0..<Int(frameCount) {
            let time = Float(frame) / Float(sampleRate)
            let sine = sin(2.0 * .pi * frequency * time)

            // Apply envelope (quick attack, quick decay)
            let envelope: Float
            let attackTime: Float = 0.005
            let decayStart: Float = 0.01

            if time < attackTime {
                envelope = time / attackTime
            } else if time < decayStart {
                envelope = 1.0
            } else {
                let decayProgress = (time - decayStart) / (Float(duration) - decayStart)
                envelope = max(0, 1.0 - decayProgress)
            }

            channelData[frame] = sine * amplitude * envelope
        }

        return buffer
    }

    private func scheduleClicks() {
        let interval = 60.0 / Double(bpm)

        // Play first click immediately
        playClick()

        // Schedule subsequent clicks
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.playClick()
        }
    }

    private func playClick() {
        guard let player = playerNode,
              let buffer = clickBuffer,
              isPlaying else { return }

        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        player.play()
    }
}
