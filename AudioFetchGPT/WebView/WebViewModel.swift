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
        webView?.isInspectable = true
    }
    
    func configureWebView(url: URL) {
        guard let webView = webView else { return }
        
        let jsScript = """
        (function() {
        
            console.log('Start handling /backend-api/synthesize')
        
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
        
        webView.configuration.userContentController.addUserScript(userScript)
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func reload() {
        webView?.reload()
    }
    
    func performSearch(text: String, forward: Bool) {
        if !text.isEmpty, let webView = webView {
            let script = "window.find('\(text)', false, \(!forward), true)"
            webView.evaluateJavaScript(script) { (result, error) in
                if let error = error {
                    print("Ошибка поиска: \(error.localizedDescription)")
                }
            }
        }
    }
}
