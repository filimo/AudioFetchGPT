//
//  AudioFetchGPTApp.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 16.09.24.
//

import SwiftUI

@main
struct AudioFetchGPTApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(DownloadedAudios())
        }
    }
}

