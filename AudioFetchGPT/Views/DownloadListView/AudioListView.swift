//
//  AudioListView.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 6.10.24.
//
import SwiftUI

extension DownloadListView {
    struct AudioListView: View {
        var audios: [DownloadedAudio]
        var onDelete: (DownloadedAudio) -> Void

        var body: some View {
            ForEach(audios) { audio in
                AudioRowView(audio: audio)
                    .id(audio.id)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            onDelete(audio)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
    }
}
