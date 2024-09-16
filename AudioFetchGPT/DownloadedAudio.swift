//
//  DownloadedAudio.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 16.09.24.
//
import Foundation

struct DownloadedAudio: Identifiable, Codable {
    var id = UUID()
    var relativePath: String
    var fileName: String
    var duration: TimeInterval? // Длительность аудио в секундах
    var downloadDate: Date // Время скачивания
    
    enum CodingKeys: String, CodingKey {
        case id
        case relativePath
        case fileName
        case duration
        case downloadDate
    }

    init(id: UUID = UUID(), url: URL, fileName: String, duration: TimeInterval?, downloadDate: Date = Date()) {
        self.id = id
        self.relativePath = url.lastPathComponent
        self.fileName = fileName
        self.duration = duration
        self.downloadDate = downloadDate
    }

    var fileURL: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent(relativePath)
    }
}



