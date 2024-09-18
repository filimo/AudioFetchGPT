//
//  AudioPlayerDelegate.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 18.09.24.
//


import AVFoundation

class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    weak var audioManager: AudioManager?
    
    init(audioManager: AudioManager) {
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
