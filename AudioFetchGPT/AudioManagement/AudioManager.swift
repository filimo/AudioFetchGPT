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
    private let timerManager = AudioTimerManager()
    private var currentAudio: DownloadedAudio?

    // Добавляем сильную ссылку на делегат
    private var audioPlayerDelegate: AudioPlayerDelegate?

    init() {
        // Создаем экземпляр делегата и сохраняем сильную ссылку
        audioPlayerDelegate = AudioPlayerDelegate(audioManager: self)
        playerManager.delegate = audioPlayerDelegate

        timerManager.updateAction = { [weak self] in
            self?.updateProgress()
        }
        
        setupRemoteCommandCenter()
        
        // Подпи��итесь на уведомления о завершении воспроизведения
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
        
        // Обновите информацию Now Playing
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
}

extension AudioManager {
    func setupNowPlaying(audio: DownloadedAudio, title: String) {
        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: title,
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
        let nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        var updatedInfo = nowPlayingInfo ?? [:]
        updatedInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        updatedInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = updatedInfo
    }
    
    func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Настройка команд воспроизведения и паузы
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
        
        // Настройка команд перемотки вперед и назад с предпочтительными интервалами
        commandCenter.skipForwardCommand.preferredIntervals = [5] // Перемотка вперед на 5 секунд
        commandCenter.skipBackwardCommand.preferredIntervals = [5] // Перемотка назад на 5 секунд
        
        commandCenter.skipForwardCommand.addTarget { [weak self] event in
            guard let self = self, let skipEvent = event as? MPSkipIntervalCommandEvent, let _ = self.currentAudio else { return .commandFailed }
            let skipTime = skipEvent.interval
            self.seekBySeconds(for: self.currentAudio!, seconds: skipTime)
            return .success
        }
        
        commandCenter.skipBackwardCommand.addTarget { [weak self] event in
            guard let self = self, let skipEvent = event as? MPSkipIntervalCommandEvent, let _ = self.currentAudio else { return .commandFailed }
            let skipTime = skipEvent.interval
            self.seekBySeconds(for: self.currentAudio!, seconds: -skipTime)
            return .success
        }
        
        // Обработка команды перемотки к определенному времени
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self,
                  let positionEvent = event as? MPChangePlaybackPositionCommandEvent,
                  let _ = self.currentAudio else { return .commandFailed }
            self.playerManager.seek(to: positionEvent.positionTime)
            self.updateProgress()
            return .success
        }
        
        // Отключение ненужных команд, если они не используются
        commandCenter.nextTrackCommand.isEnabled = false
        commandCenter.previousTrackCommand.isEnabled = false
    }
}
