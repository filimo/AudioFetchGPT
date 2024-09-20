//
//  WebView.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 16.09.24.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    @EnvironmentObject var downloadedAudios: DownloadedAudios
    
    @ObservedObject var viewModel: WebViewModel
    let url: URL
    
    // Добавляем новое свойство для поискового запроса
    @Binding var searchText: String
    @Binding var searchForward: Bool // Новое свойство для направления поиска

    func makeUIView(context: Context) -> WKWebView {
        viewModel.configureWebView(url: url)

        if let webView = viewModel.webView {
            webView.configuration.userContentController.add(context.coordinator, name: "audioHandler")
        }

        return viewModel.webView ?? WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Выполняем поиск при изменении searchText
        if !searchText.isEmpty {
            let script = "window.find('\(searchText)', false, \(!searchForward), true)"
            uiView.evaluateJavaScript(script) { (result, error) in
                if let error = error {
                    print("Ошибка поиска: \(error.localizedDescription)")
                }
            }
        }
    }

    func makeCoordinator() -> ScriptMessageHandler {
        return ScriptMessageHandler(downloadedAudios: downloadedAudios)
    }
}
