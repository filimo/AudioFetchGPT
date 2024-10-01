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
    @StateObject private var audioManager = AudioManager()
    @State private var isSheetPresented = false
    @StateObject private var webViewModel = WebViewModel()
    @State private var showNotification = false // Новое состояние для уведомления
    @State private var notificationMessage = "" // Сообщение уведомления
    @State private var searchText = "" // Новое состояние для поискового запроса
    @State private var searchForward = true // Новое состояние для направления поиска
    @State private var isSearchVisible = false // Новое состояние для видимости поиска

    let url = URL(string: "https://chatgpt.com")!

    var body: some View {
        ZStack {
            WebView(viewModel: webViewModel, url: url)

            if isSearchVisible {
                VStack {
                    SearchBar(searchText: $searchText, searchForward: $searchForward, performSearch: {
                        webViewModel.performSearch(text: searchText, forward: searchForward)
                    })
                    Spacer()
                }
            }

            VStack {
                Spacer()

                ControlButtons(isSheetPresented: $isSheetPresented, webViewModel: webViewModel, isSearchVisible: $isSearchVisible, searchText: $searchText)
            }

            if showNotification {
                NotificationView(message: notificationMessage)
            }
        }
        .sheet(isPresented: $isSheetPresented) {
            DownloadListView()
                .environmentObject(audioManager)
                .environmentObject(webViewModel)
        }
        .onAppear {
            downloadedAudios.loadDownloadedAudios()
            // Подписываемся на уведомления о завершении загрузки
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

    // Функция для показа уведомления
    private func showDownloadNotification(for audioName: String) {
        notificationMessage = audioName
        showNotification = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showNotification = false
        }
    }
}

#Preview {
    ContentView()
}
