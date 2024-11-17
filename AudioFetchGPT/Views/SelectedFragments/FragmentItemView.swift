import SwiftUI

struct FragmentItemView: View {
    let fragment: SelectedFragment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(fragment.text)
                .padding(.vertical, 4)

            Text(fragment.timestamp, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
