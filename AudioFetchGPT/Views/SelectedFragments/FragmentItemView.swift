import SwiftUI

struct FragmentItemView: View {
    let fragment: SelectedFragment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(fragment.text)
                .padding(.vertical, 4)

            Text("Conversation ID: \(fragment.conversationId)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("Message ID: \(fragment.messageId)")
                .font(.caption)
                .foregroundColor(.secondary)

            Text(fragment.timestamp, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
