//
//  ScriptMessageHandler.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 16.09.24.
//
import AVFAudio
import SwiftUI
import WebKit

class ScriptMessageHandler: NSObject, WKScriptMessageHandler {
    @ObservedObject var downloadedAudios: DownloadedAudios
    
    init(downloadedAudios: DownloadedAudios) {
        self.downloadedAudios = downloadedAudios
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "audioHandler" {
            if let body = message.body as? [String: Any] {
                if let conversationId = body["conversationId"] as? String,
                   let messageId = body["messageId"] as? String,
                   let audioData = body["audioData"] as? String
                {
                    print("conversationId: \(conversationId), messageId: \(messageId)")
                        
                    downloadAudio(from: audioData, conversationId: conversationId, messageId: messageId)
                } else {
                    print("Ошибка: Невозможно извлечь значения из объекта")
                }
            } else {
                print("Ошибка: message.body не является словарём")
            }
        }
    }

    private func downloadAudio(from url: String, conversationId: String, messageId: String) {
        guard let audioURL = URL(string: url) else { return }
        URLSession.shared.dataTask(with: audioURL) { data, _, error in
            guard let data = data, error == nil else { return }
            
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = "chatgpt_audio_\(UUID().uuidString).m4a"
            let filePath = documentsPath.appendingPathComponent(fileName)
            
            do {
                try data.write(to: filePath)
                let audioPlayer = try AVAudioPlayer(contentsOf: filePath)
                audioPlayer.prepareToPlay()
                let duration = audioPlayer.duration
                
                self.downloadedAudios.addAudio(filePath: filePath, fileName: fileName, duration: duration, conversationId: conversationId, messageId: messageId)
            } catch {
                print("Failed to save audio file: \(error)")
            }
        }.resume()
    }
}
