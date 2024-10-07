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
    @State private var collapsedSections: Set<UUID> = []
    @State private var editingConversationId: UUID?
    @State private var newConversationName: String = ""

    var groupedAudios: [UUID: [DownloadedAudio]] {
        Dictionary(grouping: downloadedAudios.items, by: { UUID(uuidString: $0.conversationId)! })
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(groupedAudios.keys.sorted(), id: \.self) { conversationId in
                    Section(header: SectionHeader(conversationId: conversationId,
                                                  conversationName: downloadedAudios.getConversationName(by: conversationId),
                                                  onEdit: { startEditing(conversationId) },
                                                  onToggle: { toggleSection(conversationId) },
                                                  isCollapsed: collapsedSections.contains(conversationId)) // Pass collapsed state
                    ) {
                        if !collapsedSections.contains(conversationId) {
                            AudioListView(audios: groupedAudios[conversationId] ?? [], onDelete: deleteAudio)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
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
        }
    }

    private func toggleSection(_ conversationId: UUID) {
        if collapsedSections.contains(conversationId) {
            collapsedSections.remove(conversationId)
        } else {
            collapsedSections.insert(conversationId)
        }
    }

    private func deleteAudio(_ audio: DownloadedAudio) {
        downloadedAudios.deleteAudio(audio)
    }

    private func startEditing(_ conversationId: UUID) {
        editingConversationId = conversationId
        newConversationName = downloadedAudios.getConversationName(by: conversationId)
    }

    private func saveNewConversationName(conversationId: UUID, newName: String) {
        downloadedAudios.updateConversationName(conversationId: conversationId, newName: newName)
    }
}
