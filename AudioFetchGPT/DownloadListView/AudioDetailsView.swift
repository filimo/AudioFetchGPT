//
//  AudioDetailsView.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 17.09.24.
//
import SwiftUI
import AVFoundation

struct AudioDetailsView: View {
    let audio: DownloadedAudio
    
    var body: some View {
        VStack(alignment: .leading) {
            if let duration = audio.duration {
                Text("Duration: \(formatDuration(duration))")
            }
            Text("Downloaded: \(formatDate(audio.downloadDate))")
        }
        .font(.subheadline)
        .foregroundColor(.gray)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

