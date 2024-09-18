//
//  AudioTimeFormatter.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 18.09.24.
//


import Foundation

struct AudioTimeFormatter {
    static func formatTime(_ time: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: time) ?? "00:00"
    }
}