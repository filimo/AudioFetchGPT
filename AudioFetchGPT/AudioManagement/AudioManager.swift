//
//  AudioManager.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 17.09.24.
//

import AVFoundation
import Combine
import MediaPlayer
import NotificationCenter
import SwiftUI

class AudioManager: ObservableObject {
    @Published var isPlaying = false
    @AppStorage("currentAudioID") var currentAudioIDString: String = ""
    @Published private(set) var currentTime: Double = 0
    @Published var messageId: String = ""

    private let playerManager = AudioPlayerManager()
    private let progressManager = AudioProgressManager()
    private var timerManager = AudioTimerManager()
    private var currentAudio: DownloadedAudio?
    private var audioPlayerDelegate: AudioPlayerDelegate?
    
    private var downloadedAudios: DownloadedAudios
    
    init(downloadedAudios: DownloadedAudios) {
        self.downloadedAudios = downloadedAudios
        audioPlayerDelegate = AudioPlayerDelegate(audioManager: self)
        playerManager.delegate = audioPlayerDelegate
        
        timerManager.updateAction = { [weak self] in
            self?.updateProgress()
        }
        
        setupRemoteCommandCenter()
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { [weak self] _ in
            self?.handleAudioFinished()
        }
    }
    
    var currentProgress: Double {
        get { progressManager.getProgress(for: currentAudioID) }
        set { progressManager.setProgress(newValue, for: currentAudioID) }
    }

    var currentAudioID: UUID {
        get { UUID(uuidString: currentAudioIDString) ?? UUID() }
        set { currentAudioIDString = newValue.uuidString }
    }
    
    func playAudio(for audio: DownloadedAudio) {
        // Проверяем, отличается ли выбрано новое аудио от текущего
        if currentAudio?.id != audio.id {
            // Подготавливаем новый аудио только если это новое аудио
            guard playerManager.preparePlayer(for: audio.fileURL) else { return }
            
            currentAudioID = audio.id
            currentAudio = audio
            seekAudio(for: audio, to: currentProgress)
        }

        if isPlaying && currentAudio?.id == audio.id {
            pauseAudio()
        } else {
            timerManager.startTimer()
            playerManager.play()
            isPlaying = true
            updateNowPlayingProgress()
            
            // Обновляем Now Playing информацию только при новом запуске
            if currentAudio?.id == audio.id {
                setupNowPlaying(audio: audio)
            }
        }
    }
    
    func pauseAudio() {
        playerManager.pause()
        isPlaying = false
        timerManager.stopTimer()
        updateNowPlayingProgress()
    }
    
    func seekAudio(for audio: DownloadedAudio, to progress: Double) {
        let newTime = progress * playerManager.duration
        playerManager.seek(to: newTime)
        progressManager.setCurrentTime(newTime, for: audio.id)
        updateNowPlayingProgress()
    }
    
    func seekBySeconds(for audio: DownloadedAudio, seconds: Double) {
        let newTime = max(0, min(playerManager.currentTime + seconds, playerManager.duration))
        playerManager.seek(to: newTime)
        currentProgress = newTime / playerManager.duration
        updateNowPlayingProgress()
    }
    
    private func updateProgress() {
        let progress = playerManager.currentTime / playerManager.duration
        currentTime = playerManager.currentTime
        progressManager.setProgress(progress, for: currentAudioID)
        progressManager.setCurrentTime(playerManager.currentTime, for: currentAudioID)
        
        // Обновляем Now Playing только если воспроизведение активно
        if isPlaying {
            updateNowPlayingProgress()
        }
    }
    
    func handleAudioFinished() {
        pauseAudio()
        playNextAudio()
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playerManager.duration
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 0.0
    }
    
    func currentTimeForAudio(_ audioID: UUID) -> String {
        let time = audioID == currentAudioID ? currentTime : progressManager.getCurrentTime(for: audioID)
        return AudioTimeFormatter.formatTime(time)
    }
    
    func progressForAudio(_ audioID: UUID) -> Double {
        return progressManager.getProgress(for: audioID)
    }
    
    func seekAudio(for audioID: UUID, to progress: Double) {
        let newTime = progress * playerManager.duration
        if currentAudio?.id == audioID {
            playerManager.seek(to: newTime)
        }
        progressManager.setCurrentTime(newTime, for: audioID)
        progressManager.setProgress(progress, for: audioID)
    }
    
    // MARK: - Remote Command Center
    
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Setup play and pause commands
        commandCenter.playCommand.addTarget { [weak self] _ in
            guard let self = self, let currentAudio = self.currentAudio else { return .commandFailed }
            self.playAudio(for: currentAudio)
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            self.pauseAudio()
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            if self.isPlaying {
                self.pauseAudio()
            } else if let currentAudio = self.currentAudio {
                self.playAudio(for: currentAudio)
            }
            return .success
        }
        
        // Setup playback position change command
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self, let positionEvent = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            self.seek(to: positionEvent.positionTime)
            return .success
        }
        
        // Enable next and previous track commands
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            self.playNextAudio()
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            self.playPreviousAudio()
            return .success
        }
    }
    
    func seek(to position: TimeInterval) {
        playerManager.seek(to: position)
        currentTime = position
        progressManager.setCurrentTime(position, for: currentAudioID)
        updateNowPlayingProgress()
    }
    
    // MARK: - Play Next/Previous Audio
    
    func playNextAudio() {
        guard let currentIndex = downloadedAudios.items.firstIndex(where: { $0.id == currentAudioID }),
              currentIndex < downloadedAudios.items.count - 1
        else {
            pauseAudio()
            return
        }
        let nextAudio = downloadedAudios.items[currentIndex + 1]
        playAudio(for: nextAudio)
        setupNowPlaying(audio: nextAudio)
    }
    
    func playPreviousAudio() {
        guard let currentIndex = downloadedAudios.items.firstIndex(where: { $0.id == currentAudioID }),
              currentIndex > 0
        else {
            pauseAudio()
            return
        }
        let previousAudio = downloadedAudios.items[currentIndex - 1]
        playAudio(for: previousAudio)
        setupNowPlaying(audio: previousAudio)
    }
    
    // MARK: - Now Playing Info
    
    func setupNowPlaying(audio: DownloadedAudio) {
        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: audio.fileName,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPMediaItemPropertyPlaybackDuration: playerManager.duration,
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
    
    func updateNowPlayingProgress() {
        guard let currentAudio = currentAudio else { return }
        
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = playerManager.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackQueueIndex] = downloadedAudios.items.firstIndex(where: { $0.id == currentAudio.id })
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackQueueCount] = downloadedAudios.items.count
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
