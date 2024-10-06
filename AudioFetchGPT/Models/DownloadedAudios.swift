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
    
    private enum UserDefaultsKeys {
        static let downloadedAudios = "downloadedAudios"
        static let savedMetaData = "savedMetaData"
    }
    
    // MARK: - Initialization
    
    init() {
        loadDownloadedAudios()
    }
    
    // MARK: - Public Methods
    
    func loadDownloadedAudios() {
        guard let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.downloadedAudios) else {
            print("No data found for downloaded audios.")
            return
        }
        do {
            let savedAudios = try JSONDecoder().decode([DownloadedAudio].self, from: data)
            items = filterExistingAudios(from: savedAudios)
        } catch {
            print("Error decoding downloaded audios: \(error)")
        }
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
            }
        } catch {
            print("Failed to delete audio: \(error)")
        }
    }
    
    func updateFileName(for uuid: UUID, name: String) {
        if let index = items.firstIndex(where: { $0.id == uuid }) {
            items[index].fileName = name
            saveDownloadedAudios()
        }
    }
    
    func updateConversationName(conversationId: UUID, newName: String) {
        for index in items.indices {
            if UUID(uuidString: items[index].conversationId) == conversationId {
                items[index].conversationName = newName
            }
        }
        saveDownloadedAudios()
    }

    func getConversationName(by conversationId: UUID) -> String {
        guard let name = items.first(where: { UUID(uuidString: $0.conversationId) == conversationId })?.conversationName else {
            return conversationId.uuidString
        }

        return name.isEmpty ? conversationId.uuidString : name
    }

    func getConversationId(byName name: String) -> String {
        return items.first { $0.conversationName == name }?.conversationId ?? "None ID"
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
}
