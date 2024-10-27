//
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 6.10.24.
//
import SwiftUI

struct EditConversationView: View {
    var conversationId: UUID
    @Binding var newConversationName: String
    var onCancel: () -> Void
    var onSave: () -> Void

    var body: some View {
        VStack {
            Text("Edit Conversation Name")
                .font(.headline)
                .padding()

            HStack {
                TextField("New Conversation Name", text: $newConversationName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: {
                    if let clipboardText = UIPasteboard.general.string {
                        newConversationName = clipboardText
                    }
                }) {
                    Image(systemName: "doc.on.clipboard")
                        .foregroundColor(.blue)
                }
                .buttonStyle(BorderlessButtonStyle()) // Чтобы избежать лишнего фона
                .padding(.leading, 8)
            }
            .padding()

            HStack {
                Button("Cancel", action: onCancel)
                Spacer()
                Button("Save", action: onSave)
                    .disabled(newConversationName.isEmpty)
            }
            .padding()
        }
        .padding()
        .presentationDetents([.fraction(1 / 4)])
    }
}

