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

    func makeUIView(context: Context) -> WKWebView {
        viewModel.configureWebView()

        viewModel.webView.configuration.userContentController.add(context.coordinator, name: "audioHandler")

        return viewModel.webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Empty implementation since the search is now handled through WebViewModel
    }

    func makeCoordinator() -> ScriptMessageHandler {
        return ScriptMessageHandler(downloadedAudios: downloadedAudios)
    }
}
