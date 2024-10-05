//
//  WebViewModel.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 16.09.24.
//

import WebKit
import SwiftUI

final class WebViewNavigationDelegate: NSObject, WKNavigationDelegate {
    weak var viewModel: WebViewModel?
    
    init(viewModel: WebViewModel) {
        self.viewModel = viewModel
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        viewModel?.gotoMessage()
        
        // Сохранение текущего URL
        if let currentURL = webView.url?.absoluteString {
            viewModel?.lastVisitedURL = currentURL
        }
    }
}
