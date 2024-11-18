import Foundation
import SwiftUI

class SelectedFragmentsStore: ObservableObject {
    private let key = "selectedFragments"

    @Published var fragments: [SelectedFragment] = [] {
        didSet {
            saveFragments()
        }
    }

    init() {
        loadFragments()
    }

    func addFragment(text: String, messageId: String, conversationId: String) {
        let fragment = SelectedFragment(text: text,
                                        messageId: messageId,
                                        conversationId: conversationId,
                                        timestamp: Date())
        fragments.append(fragment)
    }

    func removeFragment(at index: Int) {
        fragments.remove(at: index)
    }

    func updateFragment(_ fragment: SelectedFragment) {
        if let index = fragments.firstIndex(where: { $0.id == fragment.id }) {
            fragments[index] = fragment
        }
    }

    private func loadFragments() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([SelectedFragment].self, from: data) {
            fragments = decoded
        }
    }

    private func saveFragments() {
        if let encoded = try? JSONEncoder().encode(fragments) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}
