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
        
        let jsScript = try! String(contentsOf: Bundle.main.url(forResource: "script", withExtension: "js")!)
        
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
            webView.evaluateJavaScript(script) { _, error in
                if let error = error {
                    print("Ошибка поиска: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func gotoMessage(dataTestId: String) {
        let scipt = """
            document.querySelector('[data-testid="\(dataTestId)"]').scrollIntoView({
                behavior: 'smooth', // Плавная прокрутка
                block: 'start'      // Прокрутка так, чтобы элемент был в начале видимой области
            });
        """
        
        webView?.evaluateJavaScript(scipt) { _, error in
            if let error = error {
                print("Ошибка перехода: \(error.localizedDescription)")
            }
        }
    }
}
