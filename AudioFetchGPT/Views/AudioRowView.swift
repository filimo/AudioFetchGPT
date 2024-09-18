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
                get: { audioManager.progressForAudio(audio.id) },
                set: { newValue in
                    audioManager.seekAudio(for: audio.id, to: newValue)
                }
            ), in: 0...1)

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

                Text(audioManager.currentTimeForAudio(audio.id))
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
}

#Preview {
    AudioRowView(audio: .init(url: URL(string: "111")!, fileName: "1111", duration: 100), audioManager: .init())
        .padding()
}
