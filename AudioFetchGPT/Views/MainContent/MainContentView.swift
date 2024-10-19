//
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 16.09.24.
//

import AVFoundation
import SwiftUI

struct MainContentView: View {
    @EnvironmentObject var downloadedAudios: DownloadedAudioStore
    @EnvironmentObject var audioManager: PlaybackManager
    @StateObject private var webViewModel = ConversationWebViewModel()
    @State private var isSheetPresented = false
    @State private var notificationAudio: DownloadedAudio? = nil
    @State private var searchText = ""
    @State private var searchForward = true
    @State private var isSearchVisible = false

    var body: some View {
        ZStack {
            ConversationWebView(viewModel: webViewModel)
                .environmentObject(downloadedAudios)
                .environmentObject(audioManager)

            if isSearchVisible {
                VStack {
                    SearchBarView(searchText: $searchText, searchForward: $searchForward) {
                        webViewModel.performSearch(text: searchText, forward: searchForward)
                    }
                    Spacer()
                }
            }

            ControlButtonsView(
                isSheetPresented: $isSheetPresented,
                webViewModel: webViewModel,
                isSearchVisible: $isSearchVisible,
                searchText: $searchText
            )

            if let audio = notificationAudio {
                NotificationBannerView(audio: audio)
                    .onTapGesture {
                        notificationAudio = nil
                    }
            }
        }
        .sheet(isPresented: $isSheetPresented) {
            DownloadedAudiosListView()
                .environmentObject(webViewModel)
        }
        .onAppear {
            downloadedAudios.loadDownloadedAudios()
            // Subscribe to notifications about download completion
            NotificationCenter.default.addObserver(forName: .audioDownloadCompleted, object: nil, queue: .main) { notification in
                if let audio = notification.object as? DownloadedAudio {
                    showDownloadNotification(for: audio)
                }
            }
        }
        .onReceive(audioManager.$messageId) { _ in
            isSheetPresented = false
        }
    }

    // Function to show notification
    private func showDownloadNotification(for audio: DownloadedAudio?) {
        notificationAudio = audio
    }
}

#Preview {
    MainContentView()
}
