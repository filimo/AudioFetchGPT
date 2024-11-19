//
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 16.09.24.
//

import SwiftUI

@main
struct AudioFetchGPTApp: App {
    @StateObject var downloadedAudios = DownloadedAudioStore()
    @StateObject var audioManager: PlaybackManager
    
    init() {
        let downloadedAudiosInstance = DownloadedAudioStore()
        _downloadedAudios = StateObject(wrappedValue: downloadedAudiosInstance)
        _audioManager = StateObject(wrappedValue: PlaybackManager(downloadedAudios: downloadedAudiosInstance))
    }
    
    var body: some Scene {
        WindowGroup {
            MainContentView()
                .environmentObject(downloadedAudios)
                .environmentObject(audioManager)
                .environmentObject(SelectedFragmentsStore())
        }
    }
}

