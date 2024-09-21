//
//  AudioManager.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 17.09.24.
//

import AVFoundation
import Combine

class AudioManager: ObservableObject {
    @Published var isPlaying = false
    @Published var currentAudioID: UUID?
    @Published private(set) var currentTime: Double = 0

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
    }

    func pauseAudio() {
        playerManager.pause()
        isPlaying = false
        timerManager.stopTimer()
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
    }

    func handleAudioFinished() {
        pauseAudio()
    }

    func currentTimeForAudio(_ audioID: UUID) -> String {
        let time = audioID == currentAudioID ? currentTime : progressManager.getCurrentTime(for: audioID)
        return AudioTimeFormatter.formatTime(time)
    }

    func progressForAudio(_ audioID: UUID) -> Double {
        return progressManager.getProgress(for: audioID)
    }

    func seekAudio(for audioID: UUID, to progress: Double) {
        guard let audio = currentAudio, audio.id == audioID else { return }
        let newTime = progress * playerManager.duration
        playerManager.seek(to: newTime)
        progressManager.setCurrentTime(newTime, for: audioID)
        progressManager.setProgress(progress, for: audioID)
    }
}
