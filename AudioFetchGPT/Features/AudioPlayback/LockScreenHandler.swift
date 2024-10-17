//
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 8.10.24.
//

import AVFoundation
import MediaPlayer
import UIKit

class LockScreenHandler {
    private var audioManager: PlaybackManager?

    init(audioManager: PlaybackManager) {
        self.audioManager = audioManager
        setupRemoteCommandCenter()
    }

    // MARK: - Remote Command Center Setup
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [weak self] _ in
            guard let self = self, let currentAudio = self.audioManager?.currentAudio else { return .commandFailed }
            self.audioManager?.playAudio(for: currentAudio)
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            self.audioManager?.pauseAudio()
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            if self.audioManager?.isPlaying == true {
                self.audioManager?.pauseAudio()
            } else if let currentAudio = self.audioManager?.currentAudio {
                self.audioManager?.playAudio(for: currentAudio)
            }
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self, let positionEvent = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            self.audioManager?.seek(to: positionEvent.positionTime)
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            self.audioManager?.playNextAudio()
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            self.audioManager?.playPreviousAudio()
            return .success
        }
    }

    // MARK: - Now Playing Info Setup
    func setupNowPlaying(audio: DownloadedAudio, currentTime: Double, isPlaying: Bool, duration: Double) {
        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: audio.fileName,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]
        
        if let artworkImage = UIImage(named: "ArtworkImage") {
            let artwork = MPMediaItemArtwork(boundsSize: artworkImage.size) { _ in
                artworkImage
            }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    // MARK: - Update Now Playing Progress
    func updateNowPlayingProgress(currentTime: Double, isPlaying: Bool, duration: Double, queueIndex: Int?, queueCount: Int?) {
        guard MPNowPlayingInfoCenter.default().nowPlayingInfo != nil else { return }
        
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        if let queueIndex = queueIndex {
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackQueueIndex] = queueIndex
        }
        if let queueCount = queueCount {
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackQueueCount] = queueCount
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
