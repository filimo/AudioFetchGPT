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

    // закрыть попап
    @Environment(\.dismiss) var dismiss

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

            ControlButtonsView(audio: audio, audioManager: audioManager)
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    AudioRowView(audio: .init(url: URL(string: "111")!, fileName: "1111", duration: 100, dataTestId: "conversation-turn-3"), audioManager: .init())
        .padding()
}