//
//  DownloadedAudios.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 16.09.24.
//

import SwiftUI

class DownloadedAudios: ObservableObject {
    @Published var items: [DownloadedAudio] = []
    @AppStorage(UserDefaultsKeys.savedMetaData) private var savedMetaData: String = "{}"
    
    private struct UserDefaultsKeys {
        static let downloadedAudios = "downloadedAudios"
        static let savedMetaData = "savedMetaData"
    }
    
    // MARK: - Initialization
    
    init() {
        loadDownloadedAudios()
    }
    
    // MARK: - Public Methods
    
    func loadDownloadedAudios() {
        guard let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.downloadedAudios),
              let savedAudios = try? JSONDecoder().decode([DownloadedAudio].self, from: data) else {
            return
        }
        items = filterExistingAudios(from: savedAudios)
    }
    
    func addAudio(filePath: URL, fileName: String, duration: TimeInterval?, conversationId: String, messageId: String) {
        let newAudio = DownloadedAudio(url: filePath, fileName: fileName, duration: duration, conversationId: conversationId, messageId: messageId)
        items.append(newAudio)
        saveDownloadedAudios()
        notifyDownloadCompleted(fileName: fileName)
    }
    
    func deleteAudio(_ audio: DownloadedAudio) {
        do {
            try FileManager.default.removeItem(at: audio.fileURL)
            if let index = items.firstIndex(where: { $0.id == audio.id }) {
                items.remove(at: index)
                saveDownloadedAudios()
                
                // Удаление из savedMetaData
                removeName(for: audio.id)
            }
        } catch {
            print("Не удалось удалить аудио: \(error)")
        }
    }
    
    func saveName(for uuid: UUID, name: String) {
        var metadata = currentMetadata()
        metadata[uuid.uuidString] = name
        updateMetadata(with: metadata)
    }
    
    func getName(for uuid: UUID) -> String? {
        let metadata = currentMetadata()
        return metadata[uuid.uuidString]
    }
    
    // MARK: - Private Methods
    
    private func saveDownloadedAudios() {
        let existingAudios = filterExistingAudios(from: items)
        if let data = try? JSONEncoder().encode(existingAudios) {
            UserDefaults.standard.set(data, forKey: UserDefaultsKeys.downloadedAudios)
            items = existingAudios
        }
    }
    
    private func filterExistingAudios(from audios: [DownloadedAudio]) -> [DownloadedAudio] {
        audios.filter { FileManager.default.fileExists(atPath: $0.fileURL.path) }
    }
    
    private func notifyDownloadCompleted(fileName: String) {
        NotificationCenter.default.post(name: .audioDownloadCompleted, object: fileName)
    }
    
    private func currentMetadata() -> [String: String] {
        guard let data = savedMetaData.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([String: String].self, from: data) else {
            return [:]
        }
        return decoded
    }
    
    private func updateMetadata(with metadata: [String: String]) {
        if let encodedData = try? JSONEncoder().encode(metadata),
           let jsonString = String(data: encodedData, encoding: .utf8) {
            savedMetaData = jsonString
        }
    }
    
    private func removeName(for uuid: UUID) {
        var metadata = currentMetadata()
        metadata.removeValue(forKey: uuid.uuidString)
        updateMetadata(with: metadata)
    }
}
