//
//  DeleteButton.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 17.09.24.
//
import SwiftUI

struct DeleteButton: View {
    let audio: DownloadedAudio
    
    var body: some View {
        Button(action: {
            deleteAudio(audio)
        }) {
            Image(systemName: "trash")
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundColor(.red)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
    
    private func deleteAudio(_ audio: DownloadedAudio) {
        let fileURL = audio.fileURL
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("Failed to delete audio: \(error)")
        }
    }
}
