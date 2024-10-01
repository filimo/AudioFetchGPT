//
//  NotificationView.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 20.09.24.
//
import SwiftUI

// Новое представление для уведомления
struct NotificationView: View {
    var message: String

    var body: some View {
        VStack {
            Spacer()
            Text(message)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .transition(.scale)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.5))
        .edgesIgnoringSafeArea(.all)
    }
}
