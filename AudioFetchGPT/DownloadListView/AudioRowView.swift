//
//  AudioRowView.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 17.09.24.
//
import SwiftUI
import AVFoundation

struct AudioRowView: View {
    let audio: DownloadedAudio
    @ObservedObject var audioManager: AudioManager
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(audio.fileName)
                .font(.headline)
            
            AudioDetailsView(audio: audio)
            
            Slider(value: Binding(
                get: { audioManager.currentProgress[audio.id] ?? 0.0 },
                set: { newValue in
                    audioManager.currentProgress[audio.id] = newValue
                }
            ), in: 0...1, onEditingChanged: { isEditing in
                if !isEditing {
                    audioManager.seekAudio(for: audio, to: audioManager.currentProgress[audio.id] ?? 0.0)
                }
            })
            
            HStack {
                PlayPauseButton(audio: audio, audioManager: audioManager)
                
                Spacer()
                
                DeleteButton(audio: audio)
            }
        }
        .padding(.vertical, 10)
    }
}

