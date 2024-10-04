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

class AudioManager: ObservableObject {
    @Published var isPlaying = false
    @Published var currentAudioID: UUID?
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
        get { currentAudioID.flatMap { progressManager.getProgress(for: $0) } ?? 0 }
        set { if let id = currentAudioID { progressManager.setProgress(newValue, for: id) } }
    }
    
    func playAudio(for audio: DownloadedAudio) {
        guard playerManager.preparePlayer(for: audio.fileURL) else { return }
        
        if isPlaying {
            pauseAudio()
        }
        
        currentAudioID = audio.id
        currentAudio = audio
        seekAudio(for: audio, to: currentProgress)
        timerManager.startTimer()
        playerManager.play()
        isPlaying = true
        updateNowPlayingProgress()
        
        // Update Now Playing information with new title
        setupNowPlaying(audio: audio)
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
    }
    
    func seekBySeconds(for audio: DownloadedAudio, seconds: Double) {
        let newTime = max(0, min(playerManager.currentTime + seconds, playerManager.duration))
        playerManager.seek(to: newTime)
        currentProgress = newTime / playerManager.duration
    }
    
    private func updateProgress() {
        guard let audioID = currentAudioID else { return }
        let progress = playerManager.currentTime / playerManager.duration
        progressManager.setProgress(progress, for: audioID)
        progressManager.setCurrentTime(playerManager.currentTime, for: audioID)
        currentTime = playerManager.currentTime
        updateNowPlayingProgress()
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
        commandCenter.playCommand.addTarget { [weak self] event in
            guard let self = self, let currentAudio = self.currentAudio else { return .commandFailed }
            self.playAudio(for: currentAudio)
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            self.pauseAudio()
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] event in
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
            guard let self = self, let changePositionEvent = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            let newTime = changePositionEvent.positionTime
            if let currentAudio = self.currentAudio {
                self.seekAudio(for: currentAudio, to: newTime / self.playerManager.duration)
                self.updateNowPlayingProgress()
                return .success
            }
            return .commandFailed
        }
        
        // Enable next and previous track commands
        commandCenter.nextTrackCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            self.playNextAudio()
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            self.playPreviousAudio()
            return .success
        }
    }
    
    // MARK: - Play Next/Previous Audio
    
    func playNextAudio() {
        guard let currentIndex = downloadedAudios.items.firstIndex(where: { $0.id == currentAudioID }),
              currentIndex < downloadedAudios.items.count - 1 else {
            pauseAudio()
            return
        }
        let nextAudio = downloadedAudios.items[currentIndex + 1]
        playAudio(for: nextAudio)
        setupNowPlaying(audio: nextAudio)
    }
    
    func playPreviousAudio() {
        guard let currentIndex = downloadedAudios.items.firstIndex(where: { $0.id == currentAudioID }),
              currentIndex > 0 else {
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
            MPNowPlayingInfoPropertyPlaybackRate: playerManager.isPlaying ? 1.0 : 0.0,
            MPMediaItemPropertyPlaybackDuration: playerManager.duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: playerManager.currentTime
        ]
        
        if let artworkImage = UIImage(named: "ArtworkImage") {
            let artwork = MPMediaItemArtwork(boundsSize: artworkImage.size) { size in
                return artworkImage
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