//
//  AudioRowView_ControlButtons.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 24.09.24.
//

import SwiftUI

extension AudioRowView {
    struct ControlButtons: View {
        let audio: DownloadedAudio
        
        var body: some View {
            HStack {
                PlayPauseButton(audio: audio)
                
                GotoMessageButton(conversationId: audio.conversationId, messageId: audio.messageId)
                
                Spacer()
                
                SeekButtonsView(audio: audio)
                
                Spacer()
            }
        }
    }
}
