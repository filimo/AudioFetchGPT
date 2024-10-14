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
    @EnvironmentObject var audioManager: AudioManager
    let audio: DownloadedAudio
    @Binding var editableName: String
    @State private var isEditingName: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            if isEditingName {
                ZStack(alignment: .bottomTrailing) {
                    TextEditor(text: $editableName)
                        .frame(height: 400)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        .padding()

                    Button(action: {
                        downloadedAudios.updateFileName(for: audio.id, name: editableName)
                        isEditingName = false
                    }) {
                        Text("OK")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.blue)
                            .cornerRadius(8)
                            .shadow(radius: 5)
                    }
                    .padding([.trailing, .bottom], 15)
                }
                .padding(.bottom, 5)

            } else {
                Text(editableName)
                    .font(.headline)
                    .underline(audioManager.currentAudioID == audio.id, color: .yellow)
                    .truncationMode(.tail)
                    .lineLimit(1)
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
            editableName = audio.fileName
        }
    }
}
