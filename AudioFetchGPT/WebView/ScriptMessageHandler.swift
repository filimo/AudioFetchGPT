//
//  ScriptMessageHandler.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 16.09.24.
//
import AVFAudio
import SwiftUI
import WebKit
import AudioToolbox // Импортируем для воспроизведения системных звуков
import UIKit // Импортируем для использования вибрации

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
                   let audioData = body["audioData"] as? String,
                   let name = body["name"] as? String
                {
                    print("conversationId: \(conversationId), messageId: \(messageId)")
                        
                    downloadAudio(from: audioData, conversationId: conversationId, messageId: messageId, name: name)
                } else {
                    print("Error: Unable to extract values from the object")
                }
            } else {
                print("Error: message.body is not a dictionary")
            }
        }
    }

    private func downloadAudio(from url: String, conversationId: String, messageId: String, name: String) {
        guard let audioURL = URL(string: url) else { return }
        URLSession.shared.dataTask(with: audioURL) { data, _, error in
            guard let data = data, error == nil else { return }
            
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = UUID().uuidString
            let filePath = documentsPath.appendingPathComponent(fileName.appending(".m4a"))
            
            do {
                try data.write(to: filePath)
                let audioPlayer = try AVAudioPlayer(contentsOf: filePath)
                audioPlayer.prepareToPlay()
                let duration = audioPlayer.duration
                
                self.downloadedAudios.addAudio(filePath: filePath, fileName: name, duration: duration, conversationId: conversationId, messageId: messageId)
                
                self.playSignalSoundAndVibrate() // Play sound and vibrate after saving the file
            } catch {
                print("Failed to save audio file: \(error)")
            }
        }.resume()
    }
    
    private func playSignalSoundAndVibrate() {
        // Play a system sound (e.g., mail sent sound)
        AudioServicesPlaySystemSound(1013) //"Тон успеха"
        
        // Trigger device vibration
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}
