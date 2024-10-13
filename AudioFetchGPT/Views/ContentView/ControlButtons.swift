//
//  ControlButtons.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 20.09.24.
//
import SwiftUI

struct ControlButtons: View {
    @Binding var isSheetPresented: Bool
    var webViewModel: WebViewModel
    @Binding var isSearchVisible: Bool
    @Binding var searchText: String
    @State private var showMenu: Bool = false // State for showing/hiding menu

    var body: some View {
        // Floating button
        VStack {
            Spacer()

            // Show all buttons with action descriptions if menu is open
            if showMenu {
                VStack(alignment: .trailing, spacing: 16) {
                    // Previous button
                    HStack {
                        Text("Previous audio button")
                        Button(action: {
                            webViewModel.scrollToPreviousReadAloudElement()
                        }) {
                            Image(systemName: "arrow.left.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)
                        }
                    }

                    // Next button
                    HStack {
                        Text("Next audio button")
                        Button(action: {
                            webViewModel.scrollToNextReadAloudElement()
                        }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)
                        }
                    }

                    // Reload button
                    HStack {
                        Text("Reload a page")
                        Button(action: {
                            webViewModel.reload()
                        }) {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.green)
                        }
                    }

                    // Play all voice actions button
                    HStack {
                        Text("Download All Voice Messages")
                        Button(action: {
                            webViewModel.clickAllVoicePlayTurnActionButtons()
                        }) {
                            Image(systemName: "arrow.down.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.yellow)
                        }
                    }

                    // Download button
                    HStack {
                        Text("Show downloaded audios")
                        Button(action: {
                            isSheetPresented = true
                        }) {
                            Image(systemName: "music.note")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)
                        }
                    }

                    // Search button
                    HStack {
                        Text("Search")
                        Button(action: {
                            isSearchVisible.toggle()
                            if !isSearchVisible {
                                searchText = ""
                            }
                        }) {
                            Image(systemName: isSearchVisible ? "magnifyingglass.circle.fill" : "magnifyingglass")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.orange)
                        }
                    }

                    // Send from clipboard button
                    HStack {
                        Text("Send from Clipboard")
                        Button(action: {
                            if let clipboardText = UIPasteboard.general.string {
                                webViewModel.sayChatGPT(clipboardText)
                            }
                        }) {
                            Image(systemName: "paperplane.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.purple)
                        }
                    }
                }
                .transition(.move(edge: .trailing)) // Adding animation
                .padding(.bottom, 60)
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .background(Color(.systemBackground).opacity(0.7))
            }

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
        .padding(.bottom, 10) // Position the floating button at the bottom of the screen
        .padding(.trailing, 20)
    }
}
