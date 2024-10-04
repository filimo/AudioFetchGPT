//
//  ControlButtons.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 20.09.24.
//
import SwiftUI

// New view for control buttons
struct ControlButtons: View {
    @Binding var isSheetPresented: Bool
    var webViewModel: WebViewModel
    @Binding var isSearchVisible: Bool
    @Binding var searchText: String

    var body: some View {
        HStack {
            Spacer()

            // Refresh button
            Button(action: {
                webViewModel.reload()
            }) {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.green)
            }
            .padding(.trailing, 20)

            // Download button
            Button(action: {
                isSheetPresented = true
            }) {
                Image(systemName: "arrow.down.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.blue)
            }
            .padding(.trailing, 20)

            // Search button
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
            .padding(.trailing, 20)
            
            // New button for sending from clipboard
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
            .padding(.trailing, 20)
            .accessibilityLabel("Send from clipboard")
        }
        .padding(.bottom, 10)
        .padding(.trailing, 20)
    }
}
