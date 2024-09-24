//
//  DataTestButton.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 24.09.24.
//


import SwiftUI

struct DataTestButton: View {
    let dataTestId: String
    @ObservedObject var audioManager: AudioManager

    var body: some View {
        Button(action: {
            audioManager.dataTestId = dataTestId
        }) {
            Image(systemName: "arrowshape.right.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundStyle(.green)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}

#Preview {
    DataTestButton(dataTestId: "example-id", audioManager: AudioManager())
        .padding()
}