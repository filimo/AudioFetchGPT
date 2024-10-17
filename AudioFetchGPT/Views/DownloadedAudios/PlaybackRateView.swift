//
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 17.10.24.
//
import SwiftUI

struct PlaybackRateView: View {
    @EnvironmentObject var audioManager: PlaybackManager
    
    var body: some View {
        HStack {
            Text("Speed: \(audioManager.playbackRate, specifier: "%.1f")x") // Display current playback rate
            
            // Кнопка для уменьшения скорости воспроизведения
            Button(action: {
                if audioManager.playbackRate > 0.5 {
                    audioManager.setPlaybackRate(audioManager.playbackRate - 0.1)
                }
            }) {
                Image(systemName: "minus.circle")
                    .padding(.trailing, 5)
            }
            
            // Слайдер для регулировки скорости
            Slider(value: Binding(
                get: { audioManager.playbackRate },
                set: { newValue in
                    audioManager.setPlaybackRate(newValue)
                }
            ), in: 0.5 ... 2.0, step: 0.1) // Slider for selecting playback rate
            
            // Кнопка для увеличения скорости воспроизведения
            Button(action: {
                if audioManager.playbackRate < 2.0 {
                    audioManager.setPlaybackRate(audioManager.playbackRate + 0.1)
                }
            }) {
                Image(systemName: "plus.circle")
                    .padding(.leading, 5)
            }
        }
        .padding(.horizontal, 15)
    }
}
