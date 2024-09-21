//
//  AudioProgressManager.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 18.09.24.
//

import Foundation
import SwiftUI

class AudioProgressManager {
    @AppStorage("audioProgress") private var audioProgressData: String = "{}"
    @AppStorage("audioCurrentTime") private var audioCurrentTimeData: String = "{}"

    private var allProgress: [UUID: Double] {
        get {
            if let data = audioProgressData.data(using: .utf8) {
                return (try? JSONDecoder().decode([UUID: Double].self, from: data)) ?? [:]
            }
            return [:]
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let jsonString = String(data: data, encoding: .utf8)
            {
                audioProgressData = jsonString
            }
        }
    }

    private var currentTimes: [UUID: TimeInterval] {
        get {
            if let data = audioCurrentTimeData.data(using: .utf8) {
                return (try? JSONDecoder().decode([UUID: TimeInterval].self, from: data)) ?? [:]
            }
            return [:]
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let jsonString = String(data: data, encoding: .utf8)
            {
                audioCurrentTimeData = jsonString
            }
        }
    }

    func setProgress(_ progress: Double, for audioID: UUID) {
        allProgress[audioID] = progress
    }

    func getProgress(for audioID: UUID) -> Double {
        allProgress[audioID] ?? 0
    }

    func setCurrentTime(_ time: TimeInterval, for audioID: UUID) {
        currentTimes[audioID] = time
    }

    func getCurrentTime(for audioID: UUID) -> TimeInterval {
        currentTimes[audioID] ?? 0
    }

    func resetProgress(for audioID: UUID) {
        allProgress[audioID] = 0
        currentTimes[audioID] = 0
    }
}
