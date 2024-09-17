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

    func makeUIView(context: Context) -> WKWebView {
        viewModel.configureWebView(url: url)

        if let webView = viewModel.webView {
            webView.configuration.userContentController.add(context.coordinator, name: "audioHandler")
        }

        return viewModel.webView ?? WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Здесь можно обновлять представление WebView, если необходимо
    }

    func makeCoordinator() -> ScriptMessageHandler {
        return ScriptMessageHandler(downloadedAudios: downloadedAudios)
    }
}
