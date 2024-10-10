//
//  ContentView.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 16.09.24.
//

import AVFoundation
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var downloadedAudios: DownloadedAudios
    @EnvironmentObject var audioManager: AudioManager
    @StateObject private var webViewModel = WebViewModel()
    @State private var isSheetPresented = false
    @State private var showNotification = false
    @State private var notificationMessage = ""
    @State private var searchText = ""
    @State private var searchForward = true
    @State private var isSearchVisible = false

    var body: some View {
        ZStack {
            WebView(viewModel: webViewModel)
                .environmentObject(downloadedAudios)
                .environmentObject(audioManager)

            if isSearchVisible {
                VStack {
                    SearchBar(searchText: $searchText, searchForward: $searchForward) {
                        webViewModel.performSearch(text: searchText, forward: searchForward)
                    }
                    Spacer()
                }
            }

            VStack {
                Spacer()
                ControlButtons(isSheetPresented: $isSheetPresented, webViewModel: webViewModel, isSearchVisible: $isSearchVisible, searchText: $searchText)
            }

            if showNotification {
                NotificationView(message: notificationMessage)
                    .onTapGesture {
                        showNotification = false
                    }
            }
        }
        .sheet(isPresented: $isSheetPresented) {
            DownloadListView()
                .environmentObject(audioManager)
                .environmentObject(webViewModel)
        }
        .onAppear {
            downloadedAudios.loadDownloadedAudios()
            // Subscribe to notifications about download completion
            NotificationCenter.default.addObserver(forName: .audioDownloadCompleted, object: nil, queue: .main) { notification in
                if let audioName = notification.object as? String {
                    showDownloadNotification(for: audioName)
                }
            }
        }
        .onReceive(audioManager.$messageId) { messageId in
            isSheetPresented = false
        }
    }

    // Function to show notification
    private func showDownloadNotification(for audioName: String) {
        notificationMessage = audioName
        showNotification = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            showNotification = false
        }
    }
}

#Preview {
    ContentView()
}
