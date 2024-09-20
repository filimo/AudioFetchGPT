//
//  DownloadedAudios.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 16.09.24.
//

import SwiftUI

class DownloadedAudios: ObservableObject {
    @Published var items: [DownloadedAudio] = []

    func loadDownloadedAudios() {
        // Загружаем аудио из UserDefaults
        if let data = UserDefaults.standard.data(forKey: "downloadedAudios"),
           let savedAudios = try? JSONDecoder().decode([DownloadedAudio].self, from: data)
        {
            saveDownloadedAudios(items: savedAudios)
        }
    }

    func deleteAudio(_ audio: DownloadedAudio) {
        let fileURL = audio.fileURL
        do {
            try FileManager.default.removeItem(at: fileURL)
            
            saveDownloadedAudios(items: items)
        } catch {
            print("Failed to delete audio: \(error)")
        }
    }
    
    func addAudio(filePath: URL, fileName: String, duration: TimeInterval?) {
        let newAudio = DownloadedAudio(url: filePath, fileName: fileName, duration: duration)
        
        items.append(newAudio)
        
        saveDownloadedAudios(items: items)
        
        // Отправляем уведомление о завершении загрузки
        NotificationCenter.default.post(name: .audioDownloadCompleted, object: fileName)
    }

    private func saveDownloadedAudios(items: [DownloadedAudio]) {
        let existingAudios = filterExistingAudios(from: items)

        if let data = try? JSONEncoder().encode(existingAudios) {
            UserDefaults.standard.set(data, forKey: "downloadedAudios")
        }

        self.items = existingAudios
    }

    private func filterExistingAudios(from audios: [DownloadedAudio]) -> [DownloadedAudio] {
        return audios.filter { FileManager.default.fileExists(atPath: $0.fileURL.path) }
    }
}
