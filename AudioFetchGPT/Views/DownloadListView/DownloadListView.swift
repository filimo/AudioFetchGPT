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
                            .id(audio.id) // Set unique identifier
                            .onAppear {
                                // Update last visible identifier
                                lastScrolledID = audio.id
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    deleteAudio(audio)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .navigationTitle("Downloaded Audios")
                .onAppear {
                    // Scroll to the last saved position
                    if let lastID = lastScrolledID {
                        DispatchQueue.main.async {
                            proxy.scrollTo(lastID, anchor: .top)
                        }
                    }
                }
                .onDisappear {
                    // Here we can save lastScrolledID to persistent storage, e.g., UserDefaults
                    if let lastID = lastScrolledID {
                        UserDefaults.standard.set(lastID.uuidString, forKey: "LastScrolledID")
                    }
                }
            }
        }
        .onAppear {
            // Load saved identifier on appearance
            if let savedIDString = UserDefaults.standard.string(forKey: "LastScrolledID"),
               let savedID = UUID(uuidString: savedIDString)
            {
                lastScrolledID = savedID
            }
        }
    }

    private func deleteAudio(_ audio: DownloadedAudio) {
        do {
            try downloadedAudios.deleteAudio(audio)
        } catch {
            print("Failed to delete audio: \(error)")
        }
    }
}
