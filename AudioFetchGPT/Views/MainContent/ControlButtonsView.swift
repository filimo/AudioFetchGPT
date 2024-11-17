//
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
    @State private var showMenu: Bool = false
    @State private var showDownloadConfirmation: Bool = false
    @State private var textFiles: [String] = []
    @State private var showDocumentPicker = false
    @State private var showSystemPromptPicker = false
    @State private var showFragmentsSheet = false
    @StateObject private var fragmentsStore = SelectedFragmentsStore()

    var body: some View {
        VStack {
            Spacer()
            
            // Panel with menu buttons, if showMenu == true
            if showMenu {
                HStack {
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 16) {
                        // Navigation group (up, down, left, right)
                        HStack(spacing: 10) {
                            ControlButtonView(icon: "arrow.up.circle.fill", action: {
                                webViewModel.scrollToTopScreen()
                            })
                            ControlButtonView(icon: "arrow.down.circle.fill", action: {
                                webViewModel.scrollToBottomScreen()
                            })
                            ControlButtonView(icon: "arrow.left.circle.fill", action: {
                                webViewModel.scrollToPreviousReadAloudElement()
                            })
                            ControlButtonView(icon: "arrow.right.circle.fill", action: {
                                webViewModel.scrollToNextReadAloudElement()
                            })
                        }
                        
                        // Page management group (refresh and search)
                        HStack(spacing: 10) {
                            ControlButtonView(icon: "text.quote", color: .blue, label: "", action: {
                                webViewModel.getSelectedText { text in
                                    if let text = text, !text.isEmpty {
                                        fragmentsStore.addFragment(
                                            text: text,
                                            messageId: webViewModel.currentMessageId ?? "",
                                            conversationId: webViewModel.conversationId ?? ""
                                        )
                                    }
                                }
                            })
                            ControlButtonView(icon: "list.bullet.clipboard.fill", color: .green, label: "", action: {
                                showFragmentsSheet = true
                            })
                            ControlButtonView(icon: "magnifyingglass.circle.fill", color: .orange, label: "", action: {
                                isSearchVisible.toggle()
                                if !isSearchVisible { searchText = "" }
                            })
                            ControlButtonView(icon: "arrow.clockwise.circle.fill", color: .green, label: "", action: {
                                webViewModel.reload()
                            })
                        }
                        
                        // Additional buttons group (System Prompt, Clipboard, File)
                        HStack(spacing: 10) {
                            ControlButtonView(icon: "gear", color: .blue, label: "Prompts", action: {
                                showSystemPromptPicker = true
                            })
                            
                            ControlButtonView(icon: "doc.on.clipboard", color: .blue, label: "Clip", action: {
                                if let clipboardText = UIPasteboard.general.string {
                                    webViewModel.sayChatGPT("\(webViewModel.systemPrompt)\(clipboardText)")
                                }
                            })
                            
                            ControlButtonView(icon: "doc.text", color: .green, label: "File", action: {
                                showDocumentPicker = true
                            })
                        }
                        
                        // Media control group
                        HStack(spacing: 10) {
                            ControlButtonView(icon: "arrow.down.circle.fill", color: .yellow, label: "Download", action: {
                                showDownloadConfirmation = true
                            })
                            ControlButtonView(icon: "music.note", color: .blue, label: "Audios", action: {
                                isSheetPresented = true
                            })
                        }
                    }
                    .padding()
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
            }

            Spacer().frame(height: 180)
            
            // Bottom panel with menu and playback buttons
            HStack {
                Button(action: {
                    withAnimation { showMenu.toggle() }
                }) {
                    Image(systemName: showMenu ? "xmark.circle.fill" : "line.horizontal.3.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.blue)
                }
                .padding(.trailing, 10)
                
                
                Button(action: {
                    if audioManager.isPlaying {
                        audioManager.pauseAudio()
                    } else {
                        if let currentAudio = audioManager.currentAudio {
                            audioManager.playAudio(for: currentAudio)
                        }
                    }
                }) {
                    Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.blue)
                }
            }
        }
        .alert(isPresented: $showDownloadConfirmation) {
            Alert(
                title: Text("Confirm Download"),
                message: Text("Are you sure you want to download all voice messages?"),
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
        .sheet(isPresented: $showSystemPromptPicker) {
            SystemPromptPicker(showSystemPromptPicker: $showSystemPromptPicker, conversationWebViewModel: webViewModel)
        }
        .sheet(isPresented: $showFragmentsSheet) {
            SelectedFragmentsView()
                .environmentObject(fragmentsStore)
                .environmentObject(webViewModel)
        }
        .onChange(of: textFiles) { _, newValue in
            if let value = newValue.first {
                webViewModel.sayChatGPT("\(webViewModel.systemPrompt)\(value)")
            }
            textFiles = []
        }
    }
}
