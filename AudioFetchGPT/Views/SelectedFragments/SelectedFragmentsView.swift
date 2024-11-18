import SwiftUI

struct SelectedFragmentsView: View {
    @EnvironmentObject var fragmentsStore: SelectedFragmentsStore
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var webViewModel: ConversationWebViewModel

    @State private var fragmentToEdit: SelectedFragment? = nil

    var body: some View {
        NavigationView {
            List {
                ForEach(fragmentsStore.fragments) { fragment in
                    FragmentItemView(fragment: fragment)
                        .onTapGesture {
                            fragmentToEdit = fragment
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
            .sheet(item: $fragmentToEdit) { fragment in
                EditFragmentView(fragment: fragment)
                    .environmentObject(fragmentsStore)
                    .environmentObject(webViewModel)
            }
        }
    }
}
