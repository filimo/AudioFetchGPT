//
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 16.09.24.
//

import SwiftUI

class DownloadedAudioStore: ObservableObject {
    @Published var items: [DownloadedAudio] = []
    @Published var queueLength: Int = 0
    @AppStorage(UserDefaultsKeys.savedMetaData) private var savedMetaData: String = "{}"
    @AppStorage("collapsedSections") private var collapsedSectionIDs: String = "[]"

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
        notifyDownloadCompleted(audio: newAudio)
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
    
    /// Method to move audio files within a specific conversation
    func moveAudio(conversationId: UUID, indices: IndexSet, newOffset: Int) {
        // Filter audio files belonging to the specified conversation
        let conversationAudios = items.enumerated().filter { UUID(uuidString: $0.element.conversationId) == conversationId }
        
        // Extract the indices of the audio files to be moved relative to the conversation
        let audioIndices = indices.compactMap { index in
            items.firstIndex(where: { $0.id == conversationAudios[index].element.id })
        }
        
        // Get the audio files to be moved
        let movedAudios = audioIndices.map { items[$0] }
        
        // Remove the audio files from the main collection using a single change set to minimize UI updates
        items.removeAll { movedAudios.contains($0) }
        
        // Calculate the new position to insert the moved audio files
        let updatedConversationAudios = items.enumerated().filter { UUID(uuidString: $0.element.conversationId) == conversationId }
        let boundedOffset = max(0, min(newOffset, updatedConversationAudios.count))
        
        // Determine the correct index for insertion in the main collection
        let insertionIndex: Int
        if boundedOffset < updatedConversationAudios.count {
            insertionIndex = updatedConversationAudios[boundedOffset].offset
        } else {
            insertionIndex = items.endIndex
        }
        
        // Insert the moved audio files back into the collection at the calculated index
        items.insert(contentsOf: movedAudios, at: insertionIndex)
        
        // Save the changes
        saveDownloadedAudios()
    }

    var collapsedSections: Set<UUID> {
        get {
            let data = Data(collapsedSectionIDs.utf8)
            if let ids = try? JSONDecoder().decode([String].self, from: data) {
                return Set(ids.compactMap { UUID(uuidString: $0) })
            }
            return []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue.map { $0.uuidString }),
               let jsonString = String(data: data, encoding: .utf8)
            {
                collapsedSectionIDs = jsonString
            }
        }
    }
    
    func toggleSection(_ conversationId: UUID) {
        var sections = collapsedSections
        if sections.contains(conversationId) {
            sections.remove(conversationId)
        } else {
            sections.insert(conversationId)
        }
        collapsedSections = sections
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
    
    private func notifyDownloadCompleted(audio: DownloadedAudio) {
        NotificationCenter.default.post(name: .audioDownloadCompleted, object: audio)
    }

    func getDownloadedMessageIds(for conversationId: String) -> [String] {
        items
            .filter { $0.conversationId == conversationId }
            .map { $0.messageId }
    }

    func deleteConversation(conversationId: UUID) {
        // Filter audio files that do not belong to the specified conversation
        let audiosToDelete = items.filter { UUID(uuidString: $0.conversationId) == conversationId }
        
        // Delete files from the file system
        for audio in audiosToDelete {
            deleteAudio(audio)
        }
        
        // Remove audio files from the list
        items.removeAll { UUID(uuidString: $0.conversationId) == conversationId }
        
        // Save changes
        saveDownloadedAudios()
    }
}
