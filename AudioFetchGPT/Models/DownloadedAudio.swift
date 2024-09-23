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
    var dataTestId: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case relativePath
        case fileName
        case duration
        case downloadDate
        case dataTestId
    }

    init(id: UUID = UUID(), url: URL, fileName: String, duration: TimeInterval?, downloadDate: Date = Date(), dataTestId: String?) {
        self.id = id
        self.relativePath = url.lastPathComponent
        self.fileName = fileName
        self.duration = duration
        self.downloadDate = downloadDate
        self.dataTestId = dataTestId
    }

    var fileURL: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent(relativePath)
    }
}



