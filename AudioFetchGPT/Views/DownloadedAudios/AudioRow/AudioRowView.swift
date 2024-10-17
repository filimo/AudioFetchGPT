//
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 17.09.24.
//
import AVFoundation
import SwiftUI

struct AudioRowView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var audioManager: PlaybackManager

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

            HStack {
                PlayPauseButton(audio: audio)

                GotoMessageButton(conversationId: audio.conversationId, messageId: audio.messageId)

                Spacer()

                SeekButtonsView(audio: audio)

                Spacer()
            }
        }
        .padding(.vertical, 10)
    }
}
