//
//  PlayPauseButton.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 17.09.24.
//
import SwiftUI

struct PlayPauseButton: View {
    let audio: DownloadedAudio
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var downloadedAudios: DownloadedAudios

    var body: some View {
        Button(action: {
            if audioManager.isPlaying, audioManager.currentAudioID == audio.id {
                audioManager.pauseAudio()
            } else {
                audioManager.playAudio(for: audio)
                audioManager.setupNowPlaying(audio: audio, title: downloadedAudios.getName(for: audio.id) ?? audio.fileName)
            }
        }) {
            Image(systemName: (audioManager.isPlaying && audioManager.currentAudioID == audio.id) ? "pause.circle.fill" : "play.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}
