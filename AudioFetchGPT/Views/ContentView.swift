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

    // Убираем аудио-плеер и другие связанные состояния, так как они теперь в AudioManager
    @StateObject private var audioManager = AudioManager() // Используем AudioManager

    @State private var isSheetPresented = false
    @StateObject private var webViewModel = WebViewModel()
    
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
        }
        .onAppear {
            downloadedAudios.loadDownloadedAudios()
        }
        .sheet(isPresented: $isSheetPresented) {
            DownloadListView(audioManager: audioManager) // Передаем audioManager в DownloadListView
        }
    }
}


#Preview {
    ContentView()
}
