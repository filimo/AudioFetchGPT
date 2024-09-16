//
//  DownloadedAudios.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 16.09.24.
//


import SwiftUI

class DownloadedAudios: ObservableObject {
    @Published var items: [DownloadedAudio] = []
}