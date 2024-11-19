import SwiftUI

struct NoteItemView: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(note.text)
                .padding(.vertical, 4)

            Text(note.timestamp, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
