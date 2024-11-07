//
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 17.09.24.
//

import AVFoundation
import Combine
import MediaPlayer
import NotificationCenter
import SwiftUI

class PlaybackManager: ObservableObject {
    @Published var isPlaying = false
    @AppStorage("currentAudioID") private var _currentAudioIDString: String = "" // private field
    var currentAudioIDString: String {
        get { _currentAudioIDString }
        set {
            if _currentAudioIDString != newValue { // prevent recursion
                _currentAudioIDString = newValue
                synchronizeCurrentAudio()
            }
        }
    }

    @Published private(set) var currentTime: Double = 0
    @Published var messageId: String = ""
    
    @AppStorage("playbackRate") private var playbackRateStorage: Double = 1.0
    var playbackRate: Float {
        get { Float(playbackRateStorage) }
        set { playbackRateStorage = Double(newValue) }
    }

    private let playerManager = PlayerManager()
    private let progressManager = ProgressManager()
    private var timerManager = TimerManager()
    private var currentAudioPrivate: DownloadedAudio? {
        didSet {
            if let audio = currentAudioPrivate {
                currentAudioIDString = audio.id.uuidString
            } else {
                currentAudioIDString = ""
            }
        }
    }
    
    private var downloadedAudios: DownloadedAudioStore
    private var lockScreenManager: LockScreenHandler?
    
    private var audioPlayerDelegate: PlaybackDelegate?
    
    private var cancellables = Set<AnyCancellable>()

    init(downloadedAudios: DownloadedAudioStore) {
        self.downloadedAudios = downloadedAudios
        audioPlayerDelegate = PlaybackDelegate(audioManager: self)
        playerManager.delegate = audioPlayerDelegate
        
        timerManager.updateAction = { [weak self] in
            self?.updateProgress()
        }
        
        setupLockScreenManager()
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { [weak self] _ in
            self?.handleAudioFinished()
        }
        
        // Initial synchronization
        synchronizeCurrentAudio()
    }
    
    private func setupInterruptionHandling() {
        NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)
            .compactMap { $0.userInfo }
            .sink { [weak self] userInfo in
                self?.handleInterruption(userInfo: userInfo)
            }
            .store(in: &cancellables)
    }

    private func handleInterruption(userInfo: [AnyHashable: Any]) {
        guard let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue)
        else {
            return
        }

        switch type {
        case .began:
            isPlaying = false
            playerManager.pause()

        case .ended:
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    playerManager.play()
                    isPlaying = true
                }
            }

        @unknown default:
            break
        }
    }
    
    private func setupLockScreenManager() {
        lockScreenManager = LockScreenHandler(audioManager: self)
    }
    
    var currentProgress: Double {
        get { progressManager.getProgress(for: currentAudioID) }
        set { progressManager.setProgress(newValue, for: currentAudioID) }
    }

    var currentAudioID: UUID {
        get { UUID(uuidString: currentAudioIDString) ?? UUID() }
        set { currentAudioIDString = newValue.uuidString }
    }
    
    // Public property for accessing currentAudio
    var currentAudio: DownloadedAudio? {
        return currentAudioPrivate
    }
    
    /// Method to synchronize currentAudioPrivate with currentAudioIDString
    private func synchronizeCurrentAudio() {
        if let audioID = UUID(uuidString: currentAudioIDString),
           let audio = downloadedAudios.items.first(where: { $0.id == audioID })
        {
            prepareNewAudio(audio)
        } else {
            currentAudioPrivate = nil
        }
    }
    
    func playAudio(for audio: DownloadedAudio) {
        if currentAudioPrivate?.id != audio.id {
            prepareNewAudio(audio)
        }

        startPlayback(for: audio)
    }
    
    private func prepareNewAudio(_ audio: DownloadedAudio) {
        guard playerManager.preparePlayer(for: audio.fileURL) else { return }
        currentAudioID = audio.id
        currentAudioPrivate = audio
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
    
    func seek(for audio: DownloadedAudio, to progress: Double) {
        let newTime = progress * playerManager.duration
        playerManager.seek(to: newTime)
        currentTime = newTime
        progressManager.setCurrentTime(newTime, for: audio.id)
        updateNowPlayingProgress()
    }
    
    func seek(for audio: DownloadedAudio, seconds: Double) {
        if playerManager.currentTime + seconds >= playerManager.duration {
            playNextAudio()
        } else if playerManager.currentTime + seconds <= 0 {
            playPreviousAudio()
        } else {
            let newTime = playerManager.currentTime + seconds
            playerManager.seek(to: newTime)
            currentProgress = newTime / playerManager.duration
            currentTime = newTime
        }
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
        return TimeFormatter.formatTime(time)
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
              let currentIndex = downloadedAudios.items.firstIndex(where: { $0.id == currentAudio.id })
        else {
            // No current audio or it is not found in the list
            return
        }
        
        // Iterate through elements after the current one
        for nextIndex in (currentIndex + 1) ..< downloadedAudios.items.count {
            let nextAudio = downloadedAudios.items[nextIndex]
            
            // Check if conversationName matches
            if nextAudio.conversationId == currentAudio.conversationId {
                playAudio(for: nextAudio)
                return // Stop searching after finding the first match
            }
        }
        
        // If there are no matches with the same conversation name, playback can be stopped or other actions can be performed
        print("No more audios with the same conversation name")
    }

    func playPreviousAudio() {
        guard let currentAudio = currentAudioPrivate,
              let currentIndex = downloadedAudios.items.firstIndex(where: { $0.id == currentAudio.id }),
              currentIndex - 1 >= 0
        else {
            // No previous audio to play
            return
        }
        
        let previousAudio = downloadedAudios.items[currentIndex - 1]
        playAudio(for: previousAudio)
    }
    
    // MARK: - Added method for finding playback position
    
    func seek(to position: Double) {
        guard let currentAudio = currentAudioPrivate else { return }
        // Ensure that position does not exceed duration
        let clampedPosition = max(0, min(position, playerManager.duration))
        seek(for: currentAudio, to: clampedPosition / playerManager.duration)
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
