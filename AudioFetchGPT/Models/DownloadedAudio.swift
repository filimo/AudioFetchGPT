//
//  DownloadedAudio.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 16.09.24.
//
import Foundation

struct DownloadedAudio: Identifiable, Codable, Equatable { // Add Equatable conformance
    var id = UUID()
    var relativePath: String
    var fileName: String
    var duration: TimeInterval? // Audio duration in seconds
    var downloadDate: Date // Download time
    let conversationId: String
    var conversationName: String? // Conversation name made optional
    let messageId: String

    enum CodingKeys: String, CodingKey {
        case id
        case relativePath
        case fileName
        case duration
        case downloadDate
        case conversationId
        case conversationName
        case messageId
    }

    init(id: UUID = UUID(), url: URL, fileName: String, duration: TimeInterval?, downloadDate: Date = Date(), conversationId: String, conversationName: String? = nil, messageId: String) {
        self.id = id
        self.relativePath = url.lastPathComponent
        self.fileName = fileName
        self.duration = duration
        self.downloadDate = downloadDate
        self.conversationId = conversationId
        self.conversationName = conversationName ?? conversationId // Default to conversationId if nil
        self.messageId = messageId
    }

    var fileURL: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent(relativePath)
    }
}
