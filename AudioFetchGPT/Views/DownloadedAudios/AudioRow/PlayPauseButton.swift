//
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 17.09.24.
//
import SwiftUI

struct PlayPauseButton: View {
    let audio: DownloadedAudio
    @EnvironmentObject var audioManager: PlaybackManager
    @EnvironmentObject var downloadedAudios: DownloadedAudioStore

    var body: some View {
        Button(action: {
            if audioManager.isPlaying, audioManager.currentAudioID == audio.id {
                audioManager.pauseAudio()
            } else {
                audioManager.playAudio(for: audio)
                audioManager.setupNowPlaying(audio: audio)
            }
        }) {
            Image(systemName: (audioManager.isPlaying && audioManager.currentAudioID == audio.id) ? "pause.circle.fill" : "play.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}
