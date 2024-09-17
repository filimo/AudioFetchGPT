//
//  DownloadListView.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 16.09.24.
//
import AVFoundation
import SwiftUI

struct DownloadListView: View {
    @EnvironmentObject var downloadedAudios: DownloadedAudios
    @ObservedObject var audioManager: AudioManager // Используем AudioManager

    var body: some View {
        NavigationView {
            List {
                ForEach(downloadedAudios.items) { audio in
                    AudioRowView(audio: audio, audioManager: audioManager)
                }
            }
            .navigationTitle("Downloaded Audios")
        }
    }
}


