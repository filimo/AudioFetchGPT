//
//  DownloadListView.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 16.09.24.
//
import AVFoundation
import SwiftUI

struct DownloadListView: View {
    @EnvironmentObject var downloadedAudios: DownloadedAudios

    @Binding var audioPlayer: AVAudioPlayer?
    
    // Используем глобальные состояния через привязки
    @Binding var isPlaying: Bool
    @Binding var currentProgress: [UUID: Double]
    @Binding var currentAudioID: UUID?
    
    @State private var timer: Timer?

    var body: some View {
        NavigationView {
            List {
                ForEach(downloadedAudios.items) { audio in
                    VStack(alignment: .leading) {
                        Text(audio.fileName)
                            .font(.headline)
                        
                        // Отображаем длительность и время скачивания
                        VStack(alignment: .leading) {
                            if let duration = audio.duration {
                                Text("Duration: \(formatDuration(duration))")
                            }
                            Text("Downloaded: \(formatDate(audio.downloadDate))")
                        }
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        
                        // Прогресс-бар
                        Slider(value: Binding(
                            get: {
                                currentProgress[audio.id] ?? 0.0
                            },
                            set: { newValue in
                                currentProgress[audio.id] = newValue
                            }
                        ), in: 0...1, onEditingChanged: { isEditing in
                            if !isEditing {
                                seekAudio(for: audio, to: currentProgress[audio.id] ?? 0.0)
                            }
                        })
                        
                        HStack {
                            // Кнопка Play/Pause
                            Button(action: {
                                if isPlaying && currentAudioID == audio.id {
                                    pauseAudio()
                                } else {
                                    playAudio(for: audio)
                                }
                            }) {
                                Image(systemName: (isPlaying && currentAudioID == audio.id) ? "pause.circle.fill" : "play.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                            }
                            .padding(.top, 5)
                            .buttonStyle(BorderlessButtonStyle())
                            
                            Spacer()
                            
                            // Кнопка удаления аудиофайла
                            Button(action: {
                                deleteAudio(audio)
                            }) {
                                Image(systemName: "trash")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(.red)
                            }
                            .padding(.leading, 10)
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                    .padding(.vertical, 10)
                    .onAppear {
                        // Инициализируем прогресс для каждого аудио, если его еще нет
                        if currentProgress[audio.id] == nil {
                            currentProgress[audio.id] = 0.0
                        }
                        
                        // Восстанавливаем состояние проигрывания при появлении
                        if audio.id == currentAudioID, isPlaying {
                            resumeAudio(for: audio)
                        }
                    }
                }
            }
            .navigationTitle("Downloaded Audios")
        }
    }

    // Функция для воспроизведения аудио
    private func playAudio(for audio: DownloadedAudio) {
        let url = audio.fileURL
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("Audio file not found at path: \(url.path)")
            return
        }
        
        do {
            // Настраиваем аудиосессию для фонового воспроизведения
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            if audioPlayer == nil || audioPlayer?.url != url {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
            }
            
            // Устанавливаем позицию воспроизведения перед началом
            seekAudio(for: audio, to: currentProgress[audio.id] ?? 0.0)
            
            audioPlayer?.play()
            isPlaying = true
            currentAudioID = audio.id
            startTimer(for: audio)
        } catch {
            print("Failed to play audio: \(error)")
        }
    }

    // Метод для паузы аудио
    private func pauseAudio() {
        audioPlayer?.pause()
        isPlaying = false
        stopTimer()
    }

    // Функция для продолжения воспроизведения
    private func resumeAudio(for audio: DownloadedAudio) {
        guard let player = audioPlayer, player.url == audio.fileURL else {
            playAudio(for: audio)
            return
        }
        
        player.play()
        isPlaying = true
        startTimer(for: audio)
    }

    // Функция для перемотки аудио
    private func seekAudio(for audio: DownloadedAudio, to progress: Double) {
        if let player = audioPlayer {
            let newTime = progress * player.duration
            player.currentTime = newTime
        }
    }

    // Запуск таймера для обновления прогресса
    private func startTimer(for audio: DownloadedAudio) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let player = audioPlayer {
                currentProgress[audio.id] = player.currentTime / player.duration
            }
        }
    }

    // Остановка таймера
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // Форматирование длительности в mm:ss
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // Форматирование даты в строку
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    // Функция для удаления аудиофайла
    private func deleteAudio(_ audio: DownloadedAudio) {
        let fileURL = audio.fileURL
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("Failed to delete audio file: \(error)")
        }

        downloadedAudios.items.removeAll { $0.id == audio.id }
        currentProgress[audio.id] = nil
        saveDownloadedAudios()
    }

    // Сохранение списка аудиофайлов в UserDefaults
    private func saveDownloadedAudios() {
        if let data = try? JSONEncoder().encode(downloadedAudios.items) {
            UserDefaults.standard.set(data, forKey: "downloadedAudios")
        }
    }
}
