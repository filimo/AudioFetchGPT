//
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 6.10.24.
//
import SwiftUI

struct SectionHeaderView: View {
    var conversationId: UUID
    var conversationName: String
    var onEdit: () -> Void
    var onToggle: () -> Void
    var isCollapsed: Bool // Added parameter to check if section is collapsed

    var body: some View {
        HStack {
            Text(conversationName)
                .lineLimit(3)
                .truncationMode(.middle)
                .font(.headline)
                .onTapGesture {
                    onEdit()
                }
            Spacer()
            Button(action: {
                onToggle()
            }) {
                Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
                    .foregroundColor(.blue)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }
}
