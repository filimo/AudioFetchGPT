import SwiftUI

struct EditFragmentView: View {
    @EnvironmentObject var fragmentsStore: SelectedFragmentsStore
    @EnvironmentObject var webViewModel: ConversationWebViewModel
    @Environment(\.dismiss) var dismiss

    @State var fragment: SelectedFragment
    @State private var editedText: String = ""

    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $editedText)
                    .padding()
                    .onAppear {
                        editedText = fragment.text
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
                            conversationId: fragment.conversationId,
                            messageId: fragment.messageId
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
            .navigationTitle("Edit Fragment")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        fragmentsStore.updateFragment(SelectedFragment(
                            id: fragment.id,
                            text: editedText,
                            messageId: fragment.messageId,
                            conversationId: fragment.conversationId,
                            timestamp: fragment.timestamp
                        ))
                        dismiss()
                    }
                    .disabled(editedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
