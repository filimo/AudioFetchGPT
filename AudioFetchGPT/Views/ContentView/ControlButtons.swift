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

            Button(action: {
                webViewModel.reload()
            }) {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.green)
            }
            .padding(.trailing, 20)

            Button(action: {
                isSheetPresented = true
            }) {
                Image(systemName: "arrow.down.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.blue)
            }
            .padding(.trailing, 20)

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
        .padding(.bottom, 10)
        .padding(.trailing, 20)
    }
}
