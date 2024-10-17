//
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 18.09.24.
//

import AVFoundation

class PlayerManager {
    private var audioPlayer: AVAudioPlayer?
    weak var delegate: PlaybackDelegate?

    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }

    @Published var playbackRate: Float = 1.0 // Current playback rate

    func preparePlayer(for url: URL) -> Bool {
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("Audio file not found at path: \(url.path)")
            return false
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = delegate
            audioPlayer?.enableRate = true // Enable rate adjustment
            return true
        } catch {
            print("Failed to prepare audio player: \(error)")
            return false
        }
    }

    func play() {
        audioPlayer?.play()
    }

    func pause() {
        audioPlayer?.pause()
    }

    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
    }

    var currentTime: TimeInterval {
        audioPlayer?.currentTime ?? 0
    }

    var duration: TimeInterval {
        audioPlayer?.duration ?? 0
    }

    func setPlaybackRate(_ rate: Float) {
        playbackRate = rate
        audioPlayer?.rate = rate
    }
}
