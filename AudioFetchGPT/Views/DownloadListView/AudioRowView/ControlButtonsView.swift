//
//  ControlButtonsView.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 24.09.24.
//


import SwiftUI

struct ControlButtonsView: View {
    let audio: DownloadedAudio
    @ObservedObject var audioManager: AudioManager

    var body: some View {
        HStack {
            PlayPauseButton(audio: audio, audioManager: audioManager)

            if let dataTestId = audio.dataTestId {
                DataTestButton(dataTestId: dataTestId, audioManager: audioManager)
            }

            Spacer()

            SeekButtonsView(audioManager: audioManager, audio: audio)

            Spacer()

            DeleteButton(audio: audio)
        }
    }
}

