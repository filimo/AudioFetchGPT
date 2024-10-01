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
    @State private var isEditingName: Bool = false
    @Binding var editableName: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(editableName)
                .font(.headline)
                .truncationMode(.tail)
                .lineLimit(1)
                .padding(.bottom, 5)
                .onTapGesture {
                    isEditingName = true
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
        .sheet(isPresented: $isEditingName) {
            VStack {
                TextEditor(text: $editableName)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                    .padding()

                Button(action: {
                    downloadedAudios.saveName(for: audio.id, name: editableName)
                    isEditingName = false
                }) {
                    Text("Готово")
                        .foregroundColor(.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                .padding([.horizontal, .bottom])
            }
            .padding()
        }
    }
}
