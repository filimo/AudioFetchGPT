//
//  ControlButtons.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 20.09.24.
//
import SwiftUI

// Новое представление для кнопок управления
struct ControlButtons: View {
    @Binding var isSheetPresented: Bool
    var webViewModel: WebViewModel
    @Binding var isSearchVisible: Bool
    @Binding var searchText: String

    var body: some View {
        HStack {
            Spacer()

            // Кнопка "Предыдущий"
            Button(action: {
                webViewModel.scrollToPreviousReadAloudElement()
            }) {
                Image(systemName: "arrow.left.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.blue)
            }
            .padding(.trailing, 20)
            .accessibilityLabel("Прокрутить к предыдущему")

            // Кнопка "Следующий"
            Button(action: {
                webViewModel.scrollToNextReadAloudElement()
            }) {
                Image(systemName: "arrow.right.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.blue)
            }
            .padding(.trailing, 20)
            .accessibilityLabel("Прокрутить к следующему")

            // Кнопка обновления
            Button(action: {
                webViewModel.reload()
            }) {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.green)
            }
            .padding(.trailing, 20)

            // Кнопка загрузки
            Button(action: {
                isSheetPresented = true
            }) {
                Image(systemName: "arrow.down.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.blue)
            }
            .padding(.trailing, 20)

            // Кнопка поиска
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
            
            // Новая кнопка для отправки из буфера обмена
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
            .accessibilityLabel("Отправить из буфера обмена")
        }
        .padding(.bottom, 10)
        .padding(.trailing, 20)
    }
}
