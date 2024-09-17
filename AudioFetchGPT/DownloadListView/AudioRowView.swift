//
//  AudioRowView.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 17.09.24.
//
import AVFoundation
import SwiftUI

struct AudioRowView: View {
    let audio: DownloadedAudio
    @ObservedObject var audioManager: AudioManager

    var body: some View {
        VStack(alignment: .leading) {
            Text(audio.fileName)
                .font(.headline)

            AudioDetailsView(audio: audio)

            Slider(value: Binding(
                get: { audioManager.currentProgress },
                set: { newValue in
                    audioManager.currentProgress = newValue
                }
            ), in: 0 ... 1, onEditingChanged: { isEditing in
                if !isEditing {
                    audioManager.seekAudio(for: audio, to: audioManager.currentProgress)
                }
            })

            HStack {
                PlayPauseButton(audio: audio, audioManager: audioManager)

                Spacer()

                Button(action: {
                    audioManager.seekBySeconds(for: audio, seconds: -5.0)
                }) {
                    Image(systemName: "gobackward.5")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(BorderlessButtonStyle())

                // show audioManager.currentTime
                Text(formatTime(audioManager.currentTime))
                    .font(.subheadline)
                    .monospacedDigit()
                    .frame(minWidth: 50)

                Button(action: {
                    audioManager.seekBySeconds(for: audio, seconds: +5.0)
                }) {
                    Image(systemName: "goforward.5")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(BorderlessButtonStyle())

                Spacer()

                DeleteButton(audio: audio)
            }
        }
        .padding(.vertical, 10)
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: time) ?? "00:00"
    }
}

#Preview {
    AudioRowView(audio: .init(url: URL(string: "111")!, fileName: "1111", duration: 100), audioManager: .init())
        .padding()
}
