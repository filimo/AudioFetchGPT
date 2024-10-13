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
    @EnvironmentObject var webViewModel: WebViewModel
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var viewModel: WebViewModel

    @State private var editingConversationId: UUID?
    @State private var newConversationName: String = ""
    @State private var editMode: EditMode = .inactive // State for edit mode

    @State var showErrorAlert: Bool = false
    @State var errorMessage: String = ""

    var groupedAudios: [UUID: [DownloadedAudio]] {
        Dictionary(grouping: downloadedAudios.items, by: { UUID(uuidString: $0.conversationId)! })
    }

    var body: some View {
        NavigationView {
            ScrollViewReader { reader in
                List {
                    ForEach(groupedAudios.keys.sorted(), id: \.self) { conversationId in
                        Section(header: SectionHeader(conversationId: conversationId,
                                                      conversationName: downloadedAudios.getConversationName(by: conversationId),
                                                      onEdit: { startEditing(conversationId) },
                                                      onToggle: { downloadedAudios.toggleSection(conversationId) },
                                                      isCollapsed: downloadedAudios.collapsedSections.contains(conversationId))
                        ) {
                            if !downloadedAudios.collapsedSections.contains(conversationId) {
                                AudioListView(audios: groupedAudios[conversationId] ?? [],
                                              onDelete: deleteAudio,
                                              onMove: { indices, newOffset in
                                                  moveAudio(conversationId: conversationId, indices: indices, newOffset: newOffset)
                                              })
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .environment(\.editMode, $editMode) // Bind edit mode
                .toolbar {
                    EditButton() // Button to toggle edit mode
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        reader.scrollTo(audioManager.currentAudioID)
                    }
                }
            }
            .navigationTitle("Downloaded Audios")
            .sheet(isPresented: Binding<Bool>(
                get: { editingConversationId != nil },
                set: { if !$0 { editingConversationId = nil } }
            )) {
                if let conversationId = editingConversationId {
                    // Extracted view for editing conversation name
                    EditConversationView(conversationId: conversationId, newConversationName: $newConversationName, onCancel: {
                        editingConversationId = nil
                    }, onSave: {
                        saveNewConversationName(conversationId: conversationId, newName: newConversationName)
                        editingConversationId = nil
                    })
                }
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private func deleteAudio(_ audio: DownloadedAudio) {
        guard webViewModel.webView.url?.host() == "chatgpt.com" else {
            errorMessage = "Failed to remove item: Host is not chatgpt.com"
            showErrorAlert = true
            return
        }

        Task {
            do {
                try await webViewModel.removeProcessedAudioItem(conversationId: audio.conversationId, messageId: audio.messageId)
                downloadedAudios.deleteAudio(audio)
            } catch {
                print("Remove processed audio item error: \(error.localizedDescription)")
                self.errorMessage = "Failed to remove item: \(error.localizedDescription)"
                self.showErrorAlert = true
            }
        }
    }

    private func startEditing(_ conversationId: UUID) {
        editingConversationId = conversationId
        newConversationName = downloadedAudios.getConversationName(by: conversationId)
    }

    private func saveNewConversationName(conversationId: UUID, newName: String) {
        downloadedAudios.updateConversationName(conversationId: conversationId, newName: newName)
    }

    private func moveAudio(conversationId: UUID, indices: IndexSet, newOffset: Int) {
        downloadedAudios.moveAudio(conversationId: conversationId, indices: indices, newOffset: newOffset)
    }
}
