//
//  WebView.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 16.09.24.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    @ObservedObject var viewModel: WebViewModel
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        viewModel.configureWebView(url: url)
        return viewModel.webView ?? WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Здесь можно обновлять представление WebView, если необходимо
    }
}
