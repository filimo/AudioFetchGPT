import SwiftUI

struct EditNoteView: View {
    @EnvironmentObject var notesStore: NotesStore
    @EnvironmentObject var webViewModel: ConversationWebViewModel
    @Environment(\.dismiss) var dismiss

    @State var note: Note
    @State private var editedText: String = ""

    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $editedText)
                    .padding()
                    .onAppear {
                        editedText = note.text
                    }

                HStack(spacing: 16) {
                    Button(action: {
                        UIPasteboard.general.string = editedText
                    }) {
                        Text("Copy")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                    }

                    Button(action: {
                        webViewModel.gotoMessage(
                            conversationId: note.conversationId,
                            messageId: note.messageId
                        )
                        dismiss()
                    }) {
                        Text("Go")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                    }
                }
                .padding([.leading, .trailing, .bottom], 16)
            }
            .navigationTitle("Edit Note")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if notesStore.notes.contains(where: { $0.id == note.id }) {
                            notesStore.updateNote(Note(
                                id: note.id,
                                text: editedText,
                                messageId: note.messageId,
                                conversationId: note.conversationId,
                                timestamp: note.timestamp
                            ))
                        } else {
                            notesStore.addNote(
                                text: editedText,
                                messageId: note.messageId,
                                conversationId: note.conversationId
                            )
                        }
                        dismiss()
                    }
                    .disabled(editedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
