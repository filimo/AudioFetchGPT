//
//  SearchBar.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 20.09.24.
//
import SwiftUI

// Новое представление для панели поиска
struct SearchBar: View {
    @Binding var searchText: String
    @Binding var searchForward: Bool
    @Environment(\.colorScheme) var colorScheme // Добавляем это свойство

    var body: some View {
        HStack {
            ZStack(alignment: .trailing) {
                TextField("Поиск", text: $searchText)
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
            }) {
                Image(systemName: "arrow.down")
            }

            Button(action: {
                searchForward = false
            }) {
                Image(systemName: "arrow.up")
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color.black : Color.white) // Устанавливаем фон в зависимости от темы
        .foregroundColor(colorScheme == .dark ? Color.white : Color.black) // Устанавливаем цвет текста в зависимости от темы
        .shadow(radius: 5)
    }
}
