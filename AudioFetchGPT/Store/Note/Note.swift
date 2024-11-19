import Foundation
import SwiftUI

struct Note: Identifiable, Codable {
    var id = UUID()
    let text: String
    let messageId: String
    let conversationId: String
    let timestamp: Date
}

