//
//  AudioRowView.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 17.09.24.
//
import AVFoundation
import SwiftUI

struct AudioRowView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var audioManager: AudioManager

    let audio: DownloadedAudio
    @State private var editableName: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            AudioDetailsView(audio: audio, editableName: $editableName)

            Slider(value: Binding(
                get: { audioManager.progressForAudio(audio.id) },
                set: { newValue in
                    audioManager.seekAudio(for: audio.id, to: newValue)
                }
            ), in: 0 ... 1)

            ControlButtons(audio: audio)
        }
        .padding(.vertical, 10)
        .background(audio.id == audioManager.currentAudioID ? Color.yellow.opacity(0.1) : Color.clear)
    }
}
