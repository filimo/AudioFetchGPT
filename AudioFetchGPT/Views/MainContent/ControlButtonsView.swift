//
//  ControlButtonsView.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 20.09.24.
//

import SwiftUI

struct ControlButtonsView: View {
    @EnvironmentObject var downloadedAudios: DownloadedAudioStore
    @EnvironmentObject var audioManager: PlaybackManager
    @Binding var isSheetPresented: Bool
    var webViewModel: ConversationWebViewModel
    @Binding var isSearchVisible: Bool
    @Binding var searchText: String
    @EnvironmentObject var notesStore: NotesStore

    @State private var showMenu: Bool = false
    @State private var showDownloadConfirmation: Bool = false
    @State private var textFiles: [String] = []
    @State private var showDocumentPicker = false
    @State private var showSystemPromptPicker = false
    @State private var showNoteSheet = false
    @State private var noteToEdit: Note? = nil
    
    // New state for storing the text to be sent after selecting the prompt
    @State private var pendingChatGPTText: String? = nil
    
    // New state for tracking the confirmation of prompt selection
    @State private var isPromptSelected: Bool = false

    var body: some View {
        VStack {
            Spacer()
            
            // Panel with menu buttons if showMenu == true
            if showMenu {
                HStack {
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 16) {
                        // Navigation group (up, down, left, right)
                        HStack(spacing: 10) {
                            ControlButtonView(icon: "arrow.up.circle.fill", label: "Up", action: {
                                webViewModel.scrollToTopScreen()
                            })
                            ControlButtonView(icon: "arrow.down.circle.fill", label: "Down", action: {
                                webViewModel.scrollToBottomScreen()
                            })
                            ControlButtonView(icon: "arrow.left.circle.fill", label: "Left", action: {
                                webViewModel.scrollToPreviousReadAloudElement()
                            })
                            ControlButtonView(icon: "arrow.right.circle.fill", label: "Right", action: {
                                webViewModel.scrollToNextReadAloudElement()
                            })
                        }
                        
                        // Page management group (update and search)
                        HStack(spacing: 10) {
                            ControlButtonView(icon: "text.quote", color: .blue, label: "Note", action: {
                                webViewModel.getSelectedText { text in
                                    if let text = text, !text.isEmpty {
                                        let newNote = Note(
                                            text: text,
                                            messageId: webViewModel.currentMessageId ?? "",
                                            conversationId: webViewModel.conversationId ?? "",
                                            timestamp: Date()
                                        )
                                        noteToEdit = newNote
                                    }
                                }
                            })
                            ControlButtonView(icon: "list.bullet.clipboard.fill", color: .green, label: "Notes", action: {
                                showNoteSheet = true
                            })
                            ControlButtonView(icon: "magnifyingglass.circle.fill", color: .orange, label: "Search", action: {
                                isSearchVisible.toggle()
                                if !isSearchVisible { searchText = "" }
                            })
                            ControlButtonView(icon: "arrow.clockwise.circle.fill", color: .green, label: "Refresh", action: {
                                webViewModel.reload()
                            })
                        }
                        
                        // Additional buttons (System prompts, Clipboard, File)
                        HStack(spacing: 10) {
                            ControlButtonView(icon: "gear", color: .blue, label: "System prompts", action: {
                                showSystemPromptPicker = true
                                // Reset the prompt selection state when opening the selector
                                isPromptSelected = false
                            })
                            
                            ControlButtonView(icon: "doc.on.clipboard", color: .blue, label: "Clipboard", action: {
                                if let clipboardText = UIPasteboard.general.string {
                                    // Set the text to be sent after selecting the prompt
                                    pendingChatGPTText = clipboardText
                                    showSystemPromptPicker = true
                                    isPromptSelected = false
                                }
                            })
                            
                            ControlButtonView(icon: "doc.text", color: .green, label: "File", action: {
                                showDocumentPicker = true
                                isPromptSelected = false
                            })
                        }
                        
                        // Media management group
                        HStack(spacing: 10) {
                            ControlButtonView(icon: "arrow.down.circle.fill", color: .yellow, label: "Download", action: {
                                showDownloadConfirmation = true
                            })
                            ControlButtonView(icon: "music.note", color: .blue, label: "Audio", action: {
                                isSheetPresented = true
                            })
                        }
                    }
                    .padding()
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
            }

            Spacer().frame(height: 180)
            
            // Lower panel with menu and playback controls
            HStack {
                ControlButtonView(icon: showMenu ? "xmark.circle.fill" : "line.horizontal.3.circle.fill", label: "Menu", action: {
                    withAnimation { showMenu.toggle() }
                }, iconWidth: 24, iconHeight: 24)
                .padding(.trailing, 10)
                
                ControlButtonView(icon: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill", label: audioManager.isPlaying ? "Pause" : "Play", action: {
                    if audioManager.isPlaying {
                        audioManager.pauseAudio()
                    } else {
                        if let currentAudio = audioManager.currentAudio {
                            audioManager.playAudio(for: currentAudio)
                        }
                    }
                }, iconWidth: 24, iconHeight: 24)
            }
        }
        .alert(isPresented: $showDownloadConfirmation) {
            Alert(
                title: Text("Confirm download"),
                message: Text("Are you sure you want to download all audio messages?"),
                primaryButton: .default(Text("Yes"), action: {
                    if let conversationID = webViewModel.getCurrentConversationId() {
                        let downloadedMessageIDs = downloadedAudios.getDownloadedMessageIds(for: conversationID)
                        webViewModel.clickAllVoicePlayTurnActionButtons(downloadedMessageIDs: downloadedMessageIDs)
                    }
                }),
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker(textFiles: $textFiles)
        }
        .sheet(isPresented: $showSystemPromptPicker, onDismiss: {
            // After closing SystemPromptPicker, check if the prompt selection was confirmed
            if isPromptSelected, let text = pendingChatGPTText {
                let combinedText = "\(webViewModel.systemPrompt)\n\(text)"
                webViewModel.sayChatGPT(combinedText)
                pendingChatGPTText = nil
                isPromptSelected = false
            } else {
                // If the selection was canceled, reset pendingChatGPTText
                pendingChatGPTText = nil
            }
        }) {
            SystemPromptPicker(showSystemPromptPicker: $showSystemPromptPicker, conversationWebViewModel: webViewModel) {
                // Closure called when a prompt is selected
                isPromptSelected = true
            }
        }
        .sheet(isPresented: $showNoteSheet) {
            NotesView()
                .environmentObject(notesStore)
                .environmentObject(webViewModel)
        }
        .sheet(item: $noteToEdit) { note in
            EditNoteView(note: note)
                .environmentObject(notesStore)
                .environmentObject(webViewModel)
        }
        .onChange(of: textFiles) { _, newValue in
            if let value = newValue.first {
                // Set the text to be sent after selecting the prompt
                pendingChatGPTText = value
                showSystemPromptPicker = true
                isPromptSelected = false
            }
            textFiles = []
        }
    }
}

extension ControlButtonsView {
    struct ControlButtonView: View {
        let icon: String
        var color: Color = .primary
        var label: String
        var action: () -> Void
        var iconWidth: CGFloat = 30
        var iconHeight: CGFloat = 30
        
        var body: some View {
            Button(action: action) {
                VStack {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconWidth, height: iconHeight)
                        .foregroundColor(color)
                    if !label.isEmpty {
                        Text(label)
                            .font(.caption)
                            .foregroundColor(color)
                    }
                }
                .padding(.horizontal, 5)
            }
        }
    }
}
