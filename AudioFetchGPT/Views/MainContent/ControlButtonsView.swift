//
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 20.09.24.
//
import SwiftUI

struct ControlButtonsView: View {
    @EnvironmentObject var downloadedAudios: DownloadedAudioStore
    @Binding var isSheetPresented: Bool
    var webViewModel: ConversationWebViewModel
    @Binding var isSearchVisible: Bool
    @Binding var searchText: String
    @State private var showMenu: Bool = false // State for showing/hiding menu
    @State private var showDownloadConfirmation: Bool = false
    @State private var textFiles: [String] = []
    @State private var showDocumentPicker = false
    @State private var showSystemPromptPicker = false

    var body: some View {
        // Floating button
        VStack {
            Spacer()

            // Show all buttons with action descriptions if menu is open
            if showMenu {
                HStack {
                    Spacer()

                    VStack(alignment: .trailing, spacing: 20) {
                        // Navigation buttons (Previous/Next) in one line without text
                        HStack {
                            Button(action: {
                                webViewModel.scrollToTopScreen()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.blue)
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)).shadow(radius: 5))
                            }

                            Button(action: {
                                webViewModel.scrollToBottomScreen()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.down.circle.fill")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.blue)
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)).shadow(radius: 5))
                            }

                            Button(action: {
                                webViewModel.scrollToPreviousReadAloudElement()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.left.circle.fill")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.blue)
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)).shadow(radius: 5))
                            }

                            Button(action: {
                                webViewModel.scrollToNextReadAloudElement()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.blue)
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)).shadow(radius: 5))
                            }
                        }

                        // Page management buttons (Reload/Search)
                        Button(action: {
                            webViewModel.reload()
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.green)
                                Text("Reload")
                                    .foregroundColor(.primary)
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)).shadow(radius: 5))
                        }

                        Button(action: {
                            isSearchVisible.toggle()
                            if !isSearchVisible {
                                searchText = ""
                            }
                        }) {
                            HStack {
                                Image(systemName: isSearchVisible ? "magnifyingglass.circle.fill" : "magnifyingglass")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.orange)
                                Text("Search")
                                    .foregroundColor(.primary)
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)).shadow(radius: 5))
                        }

                        HStack(spacing: 10) {
                            Button(action: {
                                showSystemPromptPicker = true
                            }) {
                                HStack {
                                    Image(systemName: "gear")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.blue)
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)).shadow(radius: 5))
                            }
                            
                            // Кнопка для отправки из буфера обмена
                            Button(action: {
                                if let clipboardText = UIPasteboard.general.string {
                                    webViewModel.sayChatGPT("\(webViewModel.systemPrompt)\(clipboardText)")
                                }
                            }) {
                                HStack {
                                    Image(systemName: "doc.on.clipboard")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.blue)
                                    Text("Clip")
                                        .foregroundColor(.primary)
                                        .font(.system(size: 16, weight: .bold))
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)).shadow(radius: 5))
                            }

                            // Кнопка для отправки из файла
                            Button(action: {
                                showDocumentPicker = true
                            }) {
                                HStack {
                                    Image(systemName: "doc.text")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.green)
                                    Text("File")
                                        .foregroundColor(.primary)
                                        .font(.system(size: 16, weight: .bold))
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)).shadow(radius: 5))
                            }
                        }

                        // Media-related buttons (Download/Show audios)
                        Button(action: {
                            showDownloadConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.down.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.yellow)
                                Text("Download all voices")
                                    .foregroundColor(.primary)
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)).shadow(radius: 5))
                        }
                        .alert(isPresented: $showDownloadConfirmation) {
                            Alert(
                                title: Text("Confirm Download"),
                                message: Text("Are you sure you want to download all voice messages? This may take some time."),
                                primaryButton: .default(Text("Yes"), action: {
                                    if let converenceID = webViewModel.getCurrentConversationId() {
                                        let downloadedMessageIDs = downloadedAudios.getDownloadedMessageIds(for: converenceID)
                                        webViewModel.clickAllVoicePlayTurnActionButtons(downloadedMessageIDs: downloadedMessageIDs)
                                    }
                                }),
                                secondaryButton: .cancel()
                            )
                        }

                        Button(action: {
                            isSheetPresented = true
                        }) {
                            HStack {
                                Image(systemName: "music.note")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.blue)
                                Text("Downloaded audios")
                                    .foregroundColor(.primary)
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)).shadow(radius: 5))
                        }
                    }
                }
                .transition(.move(edge: .trailing)) // Adding animation
            }

            Spacer().frame(height: 70)

            // Floating button to show/hide menu
            Button(action: {
                withAnimation {
                    showMenu.toggle()
                }
            }) {
                Image(systemName: showMenu ? "xmark.circle.fill" : "plus.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.blue)
            }
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker(textFiles: $textFiles)
        }
        .sheet(isPresented: $showSystemPromptPicker) {
            SystemPromptPicker(showSystemPromptPicker: $showSystemPromptPicker, conversationWebViewModel: webViewModel)
        }
        .padding(.bottom, 10) // Position the floating button at the bottom of the screen
        .padding(.trailing, 20)
        .onChange(of: textFiles) { _, newValue in
            if let value = newValue.first {
                webViewModel.sayChatGPT("\(webViewModel.systemPrompt)\(value)")
            }
        }
    }
}
