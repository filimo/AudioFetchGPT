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
    @Published var currentProgress: [UUID: Double] = [:]
    
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    
    // Запуск аудио
    func playAudio(for audio: DownloadedAudio) {
        let url = audio.fileURL
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("Audio file not found at path: \(url.path)")
            return
        }

        do {
            // Настраиваем аудиосессию
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            if audioPlayer == nil || audioPlayer?.url != url {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
            }

            // Устанавливаем позицию воспроизведения
            seekAudio(for: audio, to: currentProgress[audio.id] ?? 0.0)

            audioPlayer?.play()
            isPlaying = true
            currentAudioID = audio.id
            startTimer(for: audio)
        } catch {
            print("Failed to play audio: \(error)")
        }
    }
    
    // Остановка аудио
    func pauseAudio() {
        audioPlayer?.pause()
        isPlaying = false
        stopTimer()
    }
    
    // Перемотка аудио
    func seekAudio(for audio: DownloadedAudio, to progress: Double) {
        if let player = audioPlayer {
            let newTime = progress * player.duration
            player.currentTime = newTime
        }
    }
    
    // Запуск таймера
    private func startTimer(for audio: DownloadedAudio) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let player = self.audioPlayer {
                self.currentProgress[audio.id] = player.currentTime / player.duration
            }
        }
    }

    // Остановка таймера
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
