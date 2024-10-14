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
                HStack {
                    Spacer()

                    VStack(alignment: .trailing, spacing: 20) {
                        // Navigation buttons (Previous/Next) in one line without text
                        HStack {
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
                                Text("Reload page")
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
                                Text(isSearchVisible ? "Hide search" : "Show search")
                                    .foregroundColor(.primary)
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)).shadow(radius: 5))
                        }

                        // Clipboard button
                        Button(action: {
                            if let clipboardText = UIPasteboard.general.string {
                                webViewModel.sayChatGPT(clipboardText)
                            }
                        }) {
                            HStack {
                                Image(systemName: "paperplane.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.purple)
                                Text("Send from Clipboard")
                                    .foregroundColor(.primary)
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)).shadow(radius: 5))
                        }

                        // Media-related buttons (Download/Show audios)
                        Button(action: {
                            webViewModel.clickAllVoicePlayTurnActionButtons()
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

                        Button(action: {
                            isSheetPresented = true
                        }) {
                            HStack {
                                Image(systemName: "music.note")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.blue)
                                Text("Show downloaded audios")
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
        .padding(.bottom, 10) // Position the floating button at the bottom of the screen
        .padding(.trailing, 20)
    }
}
