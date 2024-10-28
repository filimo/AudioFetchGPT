//
//  SystemPromptModel 2.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 29.10.24.
//
import Foundation

struct SystemPromptModel: Identifiable, Codable, Equatable {
    let id: UUID
    var value: String
    
    init(id: UUID = UUID(), value: String) {
        self.id = id
        self.value = value
    }
}
