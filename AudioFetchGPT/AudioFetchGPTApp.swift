//
//  AudioFetchGPTApp.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 16.09.24.
//

import SwiftUI

@main
struct AudioFetchGPTApp: App {
    @StateObject var downloadedAudios = DownloadedAudios()
    @StateObject var audioManager: AudioManager
    
    init() {
        let downloadedAudiosInstance = DownloadedAudios()
        _downloadedAudios = StateObject(wrappedValue: downloadedAudiosInstance)
        _audioManager = StateObject(wrappedValue: AudioManager(downloadedAudios: downloadedAudiosInstance))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(downloadedAudios)
                .environmentObject(audioManager)
        }
    }
}

