//
//  AudioTimerManager.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 18.09.24.
//


import Foundation

class AudioTimerManager {
    private var timer: Timer?
    var updateAction: (() -> Void)?

    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateAction?()
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
