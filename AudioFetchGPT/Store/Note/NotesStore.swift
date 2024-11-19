import Foundation
import SwiftUI

class NotesStore: ObservableObject {
    private let key = "selectedFragments"

    @Published var notes: [Note] = [] {
        didSet {
            saveNotes()
        }
    }

    init() {
        loadNotes()
    }

    func addNote(text: String, messageId: String, conversationId: String) {
        let note = Note(
            text: text,
            messageId: messageId,
            conversationId: conversationId,
            timestamp: Date()
        )
        notes.append(note)
    }

    func removeNote(at index: Int) {
        notes.remove(at: index)
    }

    func updateNote(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
        }
    }

    private func loadNotes() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Note].self, from: data) {
            notes = decoded
        }
    }

    private func saveNotes() {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}
