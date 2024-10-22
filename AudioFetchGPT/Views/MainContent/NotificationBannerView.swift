//
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 20.09.24.
//
import SwiftUI

// New view for notification
struct NotificationBannerView: View {
    var audio: DownloadedAudio
    @EnvironmentObject var audioManager: PlaybackManager
    @EnvironmentObject var downloadedAudios: DownloadedAudioStore

    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    Text("Queue length: \(downloadedAudios.queueLength)")
                        .padding(.top, 5)
                        .foregroundColor(.white)
                        .font(.subheadline)

                    Text(audio.fileName)
                        .padding()
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .transition(.scale)
                }
            }
            .frame(maxHeight: 350)
            .padding()

            Button(action: {
                if audioManager.isPlaying, audioManager.currentAudioID == audio.id {
                    audioManager.pauseAudio()
                } else {
                    audioManager.playAudio(for: audio)
                    audioManager.setupNowPlaying(audio: audio)
                }
            }) {
                HStack {
                    Image(systemName: (audioManager.isPlaying && audioManager.currentAudioID == audio.id) ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)).shadow(radius: 5))
            }
            .padding()
        }
        .background(Color.black.opacity(0.5))
        .padding()
    }
}
