import SwiftUI

struct SelectedFragmentsView: View {
    @EnvironmentObject var fragmentsStore: SelectedFragmentsStore
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var webViewModel: ConversationWebViewModel

    var body: some View {
        NavigationView {
            List {
                ForEach(fragmentsStore.fragments) { fragment in
                    FragmentItemView(fragment: fragment)
                        .onTapGesture {
                            webViewModel.gotoMessage(
                                conversationId: fragment.conversationId,
                                messageId: fragment.messageId
                            )
                            dismiss()
                        }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        fragmentsStore.removeFragment(at: index)
                    }
                }
            }
            .navigationTitle("Selected Fragments")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
