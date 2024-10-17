//
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 24.09.24.
//

import SwiftUI

struct SeekButtonsView: View {
    @EnvironmentObject var audioManager: PlaybackManager
    let audio: DownloadedAudio

    var body: some View {
        HStack {
            Button(action: {
                audioManager.seekBySeconds(for: audio, seconds: -5.0)
            }) {
                Image(systemName: "gobackward.5")
                    .resizable()
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(BorderlessButtonStyle())

            Text(audioManager.currentTimeForAudio(audio.id))
                .font(.subheadline)
                .monospacedDigit()
                .frame(minWidth: 50)

            Button(action: {
                audioManager.seekBySeconds(for: audio, seconds: +5.0)
            }) {
                Image(systemName: "goforward.5")
                    .resizable()
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }
}
