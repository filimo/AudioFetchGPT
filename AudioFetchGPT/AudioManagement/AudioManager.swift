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
    
    @AppStorage("playbackRate") private var playbackRateStorage: Double = 1.0
    var playbackRate: Float {
        get { Float(playbackRateStorage) }
        set { playbackRateStorage = Double(newValue) }
    }

    private let playerManager = AudioPlayerManager()
    private let progressManager = AudioProgressManager()
    private var timerManager = AudioTimerManager()
    private var currentAudioPrivate: DownloadedAudio?
    private var audioPlayerDelegate: AudioPlayerDelegate?
    
    private var downloadedAudios: DownloadedAudios
    private var lockScreenManager: LockScreenManager?

    init(downloadedAudios: DownloadedAudios) {
        self.downloadedAudios = downloadedAudios
        audioPlayerDelegate = AudioPlayerDelegate(audioManager: self)
        playerManager.delegate = audioPlayerDelegate
        
        timerManager.updateAction = { [weak self] in
            self?.updateProgress()
        }
        
        setupLockScreenManager()
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { [weak self] _ in
            self?.handleAudioFinished()
        }
    }
    
    private func setupLockScreenManager() {
        lockScreenManager = LockScreenManager(audioManager: self)
    }
    
    var currentProgress: Double {
        get { progressManager.getProgress(for: currentAudioID) }
        set { progressManager.setProgress(newValue, for: currentAudioID) }
    }

    var currentAudioID: UUID {
        get { UUID(uuidString: currentAudioIDString) ?? UUID() }
        set { currentAudioIDString = newValue.uuidString }
    }
    
    // Публичное свойство для доступа к currentAudio
    var currentAudio: DownloadedAudio? {
        return currentAudioPrivate
    }
    
    func playAudio(for audio: DownloadedAudio) {
        if currentAudioPrivate?.id != audio.id {
            prepareNewAudio(audio)
        }

        togglePlayPause(for: audio)
    }
    
    private func prepareNewAudio(_ audio: DownloadedAudio) {
        guard playerManager.preparePlayer(for: audio.fileURL) else { return }
        currentAudioID = audio.id
        currentAudioPrivate = audio
        seekAudio(for: audio, to: currentProgress)
        setPlaybackRate(Float(playbackRate))
    }
    
    private func togglePlayPause(for audio: DownloadedAudio) {
        if isPlaying && currentAudioPrivate?.id == audio.id {
            pauseAudio()
        } else {
            startPlayback(for: audio)
        }
    }
    
    private func startPlayback(for audio: DownloadedAudio) {
        timerManager.startTimer()
        playerManager.play()
        isPlaying = true
        updateNowPlayingProgress()
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
        currentTime = newTime
        progressManager.setCurrentTime(newTime, for: audio.id)
        updateNowPlayingProgress()
    }
    
    func seekBySeconds(for audio: DownloadedAudio, seconds: Double) {
        let newTime = max(0, min(playerManager.currentTime + seconds, playerManager.duration))
        playerManager.seek(to: newTime)
        currentProgress = newTime / playerManager.duration
        currentTime = newTime
        updateNowPlayingProgress()
    }
    
    private func updateProgress() {
        let progress = playerManager.currentTime / playerManager.duration
        currentTime = playerManager.currentTime
        progressManager.setProgress(progress, for: currentAudioID)
        progressManager.setCurrentTime(playerManager.currentTime, for: currentAudioID)
        
        if isPlaying {
            updateNowPlayingProgress()
        }
    }
    
    func handleAudioFinished() {
        pauseAudio()
        playNextAudio()
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
        if currentAudioPrivate?.id == audioID {
            playerManager.seek(to: newTime)
            currentTime = newTime
        }
        progressManager.setCurrentTime(newTime, for: audioID)
        progressManager.setProgress(progress, for: audioID)
        updateNowPlayingProgress()
    }
    
    // MARK: - Now Playing Info
    
    func setupNowPlaying(audio: DownloadedAudio) {
        lockScreenManager?.setupNowPlaying(audio: audio, currentTime: currentTime, isPlaying: isPlaying, duration: playerManager.duration)
    }
    
    private func updateNowPlayingProgress() {
        guard let currentAudio = currentAudio else { return }
        
        let queueIndex = downloadedAudios.items.firstIndex(where: { $0.id == currentAudio.id })
        let queueCount = downloadedAudios.items.count
        
        lockScreenManager?.updateNowPlayingProgress(currentTime: currentTime, isPlaying: isPlaying, duration: playerManager.duration, queueIndex: queueIndex, queueCount: queueCount)
    }
    
    // MARK: - Playback Controls
    
    func playNextAudio() {
        guard let currentAudio = currentAudioPrivate,
              let currentIndex = downloadedAudios.items.firstIndex(where: { $0.id == currentAudio.id }),
              currentIndex + 1 < downloadedAudios.items.count
        else {
            // Нет следующего аудио для воспроизведения
            return
        }
        
        let nextAudio = downloadedAudios.items[currentIndex + 1]
        playAudio(for: nextAudio)
    }
    
    func playPreviousAudio() {
        guard let currentAudio = currentAudioPrivate,
              let currentIndex = downloadedAudios.items.firstIndex(where: { $0.id == currentAudio.id }),
              currentIndex - 1 >= 0
        else {
            // Нет предыдущего аудио для воспроизведения
            return
        }
        
        let previousAudio = downloadedAudios.items[currentIndex - 1]
        playAudio(for: previousAudio)
    }
    
    // MARK: - Добавленный метод для поиска позиции воспроизведения
    
    func seek(to position: Double) {
        guard let currentAudio = currentAudioPrivate else { return }
        // Убедимся, что position не превышает длительность
        let clampedPosition = max(0, min(position, playerManager.duration))
        seekAudio(for: currentAudio, to: clampedPosition / playerManager.duration)
    }
    
    func changePlaybackRate(to rate: Float) {
        playbackRate = rate
        playerManager.setPlaybackRate(rate)
    }
    
    func setPlaybackRate(_ rate: Float) {
        playbackRate = rate
        playerManager.setPlaybackRate(rate)
    }
}
