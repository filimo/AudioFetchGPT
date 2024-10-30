//
//  ControlButtonView.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 30.10.24.
//


import SwiftUI

struct ControlButtonView: View {
    let icon: String
    var color: Color = .blue
    var label: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(color)
                if let label = label {
                    Text(label)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.primary)
                }
            }
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)).shadow(radius: 3))
        }
    }
}
