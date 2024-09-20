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
    
    let url = URL(string: "https://chatgpt.com")!

    var body: some View {
        ZStack {
            WebView(viewModel: webViewModel, url: url)

            VStack {
                Spacer()
                HStack {
                    // Кнопка обновления
                    Button(action: {
                        webViewModel.reload()
                    }) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .padding(20)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 10)
                    }
                    .padding(.trailing, 20)

                    // Кнопка показа списка загрузок
                    Button(action: {
                        isSheetPresented = true
                    }) {
                        Image(systemName: "arrow.down.circle.fill")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .padding(20)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 10)
                    }
                    .padding(.trailing, 20)
                }
            }
            
            // Уведомление
            if showNotification {
                VStack {
                    Text(notificationMessage)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .transition(.move(edge: .top))
                }
                .animation(.easeInOut, value: showNotification)
                .zIndex(1) // Чтобы уведомление было поверх других элементов
            }
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
        .sheet(isPresented: $isSheetPresented) {
            DownloadListView(audioManager: audioManager) // Передаем audioManager в DownloadListView
        }
    }
    
    // Функция для показа уведомления
    private func showDownloadNotification(for audioName: String) {
        notificationMessage = "Аудио '\(audioName)' успешно скачано"
        showNotification = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showNotification = false
        }
    }
}


#Preview {
    ContentView()
}
