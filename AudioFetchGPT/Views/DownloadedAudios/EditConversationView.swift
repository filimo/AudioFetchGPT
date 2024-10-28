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
    var onDelete: () -> Void // Параметр для удаления

    @State private var showDeleteConfirmation = false // Состояние для показа алерта

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
                .buttonStyle(BorderlessButtonStyle())
                .padding(.leading, 8)
            }
            .padding()

            HStack {
                Button("Cancel", action: onCancel)
                Spacer()
                Button("Delete", action: {
                    showDeleteConfirmation = true // Показываем алерт
                })
                .foregroundColor(.red)
                .alert(isPresented: $showDeleteConfirmation) { // Настраиваем алерт
                    Alert(
                        title: Text("Confirm Deletion"),
                        message: Text("Are you sure you want to delete this conversation and all related audio files?"),
                        primaryButton: .destructive(Text("Delete"), action: onDelete), // Подтверждение удаления
                        secondaryButton: .cancel() // Кнопка отмены
                    )
                }
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


