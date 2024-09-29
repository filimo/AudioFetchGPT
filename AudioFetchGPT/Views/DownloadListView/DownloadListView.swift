//
//  DownloadListView.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 16.09.24.
//
import AVFoundation
import SwiftUI

struct DownloadListView: View {
    @EnvironmentObject var downloadedAudios: DownloadedAudios
    @State private var lastScrolledID: UUID?

    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                List {
                    ForEach(downloadedAudios.items) { audio in
                        AudioRowView(audio: audio)
                            .id(audio.id) // Устанавливаем уникальный идентификатор
                            .onAppear {
                                // Обновляем последний видимый идентификатор
                                lastScrolledID = audio.id
                            }
                    }
                }
                .navigationTitle("Downloaded Audios")
                .onAppear {
                    // Прокручиваем к последнему сохранённому положению
                    if let lastID = lastScrolledID {
                        DispatchQueue.main.async {
                            proxy.scrollTo(lastID, anchor: .top)
                        }
                    }
                }
                .onDisappear {
                    // Здесь можно сохранить lastScrolledID в постоянное хранилище, например, UserDefaults
                    if let lastID = lastScrolledID {
                        UserDefaults.standard.set(lastID.uuidString, forKey: "LastScrolledID")
                    }
                }
            }
        }
        .onAppear {
            // Загружаем сохранённый идентификатор при появлении
            if let savedIDString = UserDefaults.standard.string(forKey: "LastScrolledID"),
               let savedID = UUID(uuidString: savedIDString) {
                lastScrolledID = savedID
            }
        }
    }
}


