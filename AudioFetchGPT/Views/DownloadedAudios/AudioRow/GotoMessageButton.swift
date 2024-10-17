//
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 24.09.24.
//

import SwiftUI

struct GotoMessageButton: View {
    let conversationId: String
    let messageId: String
    @EnvironmentObject var audioManager: PlaybackManager
    @EnvironmentObject var webViewModel: ConversationWebViewModel

    var body: some View {
        Button(action: {
            audioManager.messageId = messageId
            webViewModel.gotoMessage(conversationId: conversationId, messageId: messageId)
        }) {
            Image(systemName: "arrowshape.right.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundStyle(.green)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}
