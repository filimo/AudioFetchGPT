//
//  DeleteButton.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 17.09.24.
//
import SwiftUI

struct DeleteButton: View {
    @EnvironmentObject var downloadedAudios: DownloadedAudios
    
    let audio: DownloadedAudio
    
    var body: some View {
        Button(action: {
            downloadedAudios.deleteAudio(audio)
        }) {
            Image(systemName: "trash")
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundColor(.red)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}
