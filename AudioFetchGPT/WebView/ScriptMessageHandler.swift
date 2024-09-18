//
//  ScriptMessageHandler.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 16.09.24.
//
import WebKit
import SwiftUI
import AVFAudio

class ScriptMessageHandler: NSObject, WKScriptMessageHandler {
    @ObservedObject var downloadedAudios: DownloadedAudios
    
    init(downloadedAudios: DownloadedAudios) {
        self.downloadedAudios = downloadedAudios
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "audioHandler", let audioUrl = message.body as? String {
            downloadAudio(from: audioUrl)
        }
    }

    private func downloadAudio(from url: String) {
        guard let audioURL = URL(string: url) else { return }
        URLSession.shared.dataTask(with: audioURL) { data, response, error in
            guard let data = data, error == nil else { return }
            
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = "chatgpt_audio_\(UUID().uuidString).m4a"
            let filePath = documentsPath.appendingPathComponent(fileName)
            
            do {
                try data.write(to: filePath)
                let audioPlayer = try AVAudioPlayer(contentsOf: filePath)
                let duration = audioPlayer.duration
                
                self.downloadedAudios.addAudio(filePath: filePath, fileName: fileName, duration: duration)
            } catch {
                print("Failed to save audio file: \(error)")
            }
        }.resume()
    }
}
