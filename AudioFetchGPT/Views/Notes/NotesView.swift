import SwiftUI

struct NotesView: View {
    @EnvironmentObject var notesStore: NotesStore
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var webViewModel: ConversationWebViewModel

    @State private var noteToEdit: Note? = nil

    var body: some View {
        NavigationView {
            List {
                ForEach(notesStore.notes) { note in
                    NoteItemView(note: note)
                        .onTapGesture {
                            noteToEdit = note
                        }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        notesStore.removeNote(at: index)
                    }
                }
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $noteToEdit) { note in
                EditNoteView(note: note)
                    .environmentObject(notesStore)
                    .environmentObject(webViewModel)
            }
        }
    }
}
