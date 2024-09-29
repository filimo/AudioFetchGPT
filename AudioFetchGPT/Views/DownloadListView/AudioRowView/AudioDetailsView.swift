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
    @State private var isEditingName: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            if isEditingName {
                TextField("Название аудио", text: $editableName, onCommit: {
                    downloadedAudios.saveName(for: audio.id, name: editableName)
                    isEditingName = false
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 5)
            } else {
                Text(editableName)
                    .font(.headline)
                    .truncationMode(.middle) // Использование нативного метода обрезки середины
                    .lineLimit(1) // Ограничение до одной строки
                    .padding(.bottom, 5)
                    .onTapGesture {
                        isEditingName = true
                    }
            }

            HStack {
                Text("\(AudioTimeFormatter.formatDate(audio.downloadDate))")

                if let duration = audio.duration {
                    Text("Duration: \(AudioTimeFormatter.formatTime(duration))")
                }
                Spacer()
            }
            .font(.subheadline)
            .foregroundColor(.gray)
        }
        .onAppear {
            editableName = downloadedAudios.getName(for: audio.id) ?? audio.fileName
        }
    }
}
