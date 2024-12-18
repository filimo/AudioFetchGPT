//
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 6.10.24.
//  Modified to support reordering by [Your Name] on [Date].
//

import SwiftUI

struct AudioListView: View {
    var audios: [DownloadedAudio]
    var onDelete: (DownloadedAudio) -> Void
    var onMove: (IndexSet, Int) -> Void // Callback for moving items
    var onShare: (DownloadedAudio) -> Void

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

                    Button {
                        onShare(audio)
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
        }
        .onMove(perform: onMove) // Enable moving
    }
}
