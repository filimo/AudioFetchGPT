//
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 18.09.24.
//


import AVFoundation

class PlaybackDelegate: NSObject, AVAudioPlayerDelegate {
    weak var audioManager: PlaybackManager?
    
    init(audioManager: PlaybackManager) {
        self.audioManager = audioManager
        super.init()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard flag else { return }
        DispatchQueue.main.async { [weak self] in
            self?.audioManager?.handleAudioFinished()
        }
    }
}
