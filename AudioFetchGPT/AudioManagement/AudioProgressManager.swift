//
//  AudioProgressManager.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 18.09.24.
//


import Foundation

class AudioProgressManager {
    private var allProgress: [UUID: Double] = [:]
    private var currentTimes: [UUID: TimeInterval] = [:]

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