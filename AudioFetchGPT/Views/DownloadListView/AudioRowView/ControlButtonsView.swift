//
//  ControlButtonsView.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 24.09.24.
//


import SwiftUI

struct ControlButtonsView: View {
    let audio: DownloadedAudio

    var body: some View {
        HStack {
            PlayPauseButton(audio: audio)

            if let dataTestId = audio.dataTestId {
                DataTestButton(dataTestId: dataTestId)
            }

            Spacer()

            SeekButtonsView(audio: audio)

            Spacer()

            DeleteButton(audio: audio)
        }
    }
}

