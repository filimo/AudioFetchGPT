//
//  WebViewModel.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 16.09.24.
//


import SwiftUI
import WebKit

final class WebViewModel: ObservableObject {
    @Published var webView: WKWebView?
    
    init() {
        self.webView = WKWebView()
    }
    
    func configureWebView(url: URL) {
        guard let webView = self.webView else { return }
        
        let contentController = WKUserContentController()
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = contentController
        
        let jsScript = """
        (function() {
            var originalFetch = window.fetch;
            window.fetch = function(input, init) {
                if (typeof input === 'string' && input.includes('/backend-api/synthesize')) {
                    return originalFetch(input, init).then(response => {
                        response.clone().blob().then(blob => {
                            var reader = new FileReader();
                            reader.onloadend = function() {
                                window.webkit.messageHandlers.audioHandler.postMessage(reader.result);
                            };
                            reader.readAsDataURL(blob);
                        });
                        return response;
                    });
                }
                return originalFetch(input, init);
            };
        })();
        """
        
        let userScript = WKUserScript(source: jsScript, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        contentController.addUserScript(userScript)
        
        webView.configuration.userContentController = contentController
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func reload() {
        webView?.reload()
    }
}
