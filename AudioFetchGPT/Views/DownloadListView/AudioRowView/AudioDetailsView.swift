//
//  AudioDetailsView.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 17.09.24.
//
import AVFoundation
import SwiftUI

struct AudioDetailsView: View {
    @EnvironmentObject var downloadedAudios: DownloadedAudios
    let audio: DownloadedAudio
    @State private var editableName: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            TextField("Название аудио", text: $editableName, onCommit: {
                downloadedAudios.saveName(for: audio.id, name: editableName)
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.bottom, 5)
            .onAppear {
                editableName = downloadedAudios.getName(for: audio.id) ?? audio.fileName
            }

            HStack {
                Text("\(formatDate(audio.downloadDate))")

                if let duration = audio.duration {
                    Text("Duration: \(formatDuration(duration))")
                }
                Spacer()
            }
            .font(.subheadline)
            .foregroundColor(.gray)
        }
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
