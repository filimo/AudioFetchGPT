//
//  SearchBar.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 20.09.24.
//
import SwiftUI

// New view for search bar
struct SearchBar: View {
    @Binding var searchText: String
    @Binding var searchForward: Bool
    var performSearch: () -> Void // New property
    @Environment(\.colorScheme) var colorScheme // Add this property

    var body: some View {
        HStack {
            ZStack(alignment: .trailing) {
                TextField("Search", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                    }
                }
            }

            Button(action: {
                searchForward = true
                performSearch()
            }) {
                Image(systemName: "arrow.down")
            }

            Button(action: {
                searchForward = false
                performSearch()
            }) {
                Image(systemName: "arrow.up")
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color.black : Color.white) // Set background depending on theme
        .foregroundColor(colorScheme == .dark ? Color.white : Color.black) // Set text color depending on theme
        .shadow(radius: 5)
    }
}
