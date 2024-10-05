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
    
    @AppStorage("lastVisitedURL") var lastVisitedURL: String = "https://chatgpt.com"
    
    private var navigationDelegate: WebViewNavigationDelegate?
    private var targetMessageId: String?
    private var currentReadAloudIndex: Int = 0
    
    init() {
        self.webView = WKWebView()
        webView?.isInspectable = true
        setupNavigationDelegate()
    }
    
    private func setupNavigationDelegate() {
        let delegate = WebViewNavigationDelegate(viewModel: self)
        navigationDelegate = delegate
        webView?.navigationDelegate = delegate
    }
    
    func configureWebView() {
        guard let webView = webView else { return }
        
        do {
            // Загрузка JavaScript скрипта
            let jsScriptURL = Bundle.main.url(forResource: "script", withExtension: "js")
            guard let jsScriptURL = jsScriptURL else { throw NSError(domain: "Invalid script URL", code: 0) }
            let jsScript = try String(contentsOf: jsScriptURL, encoding: .utf8)
            
            let userScript = WKUserScript(source: jsScript, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            webView.configuration.userContentController.addUserScript(userScript)
        } catch {
            print("Error loading JavaScript: \(error.localizedDescription)")
            return
        }
        
        let url = URL(string: lastVisitedURL)!
        
        let request = URLRequest(url: url)
        webView.load(request)
        
        // Сохранение текущего URL
        DispatchQueue.main.async {
            self.lastVisitedURL = url.absoluteString
        }
    }
    
    func reload() {
        webView?.reload()
    }
    
    func performSearch(text: String, forward: Bool) {
        guard !text.isEmpty, let webView = webView else { return }
        
        let script = "window.find('\(text)', false, \(!forward), true)"
        webView.evaluateJavaScript(script) { _, error in
            if let error = error {
                print("Search error: \(error.localizedDescription)")
            }
        }
    }
    
    func gotoMessage(conversationId: String, messageId: String) {
        guard let webView = webView else { return }
        
        if let url = URL(string: "https://chatgpt.com/c/\(conversationId)") {
            if webView.url?.absoluteString == url.absoluteString {
                gotoMessage(messageId: messageId)
            } else {
                targetMessageId = messageId
                webView.load(URLRequest(url: url))
            }
        }
    }
    
    func gotoMessage(messageId: String) {
        let script = """
            document.querySelector('[data-message-id="\(messageId)"]').scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        """
        
        webView?.evaluateJavaScript(script) { _, error in
            if let error = error {
                print("Navigation error: \(error.localizedDescription)")
            }
        }
    }
    
    func gotoMessage() {
        guard let webView = webView,
              let messageId = targetMessageId else { return }
        
        let script = """
        function waitForElement(selector, callback) {
            const observer = new MutationObserver((mutations, obs) => {
                const element = document.querySelector(selector);
                if (element) {
                    obs.disconnect();
                    callback(element);
                }
            });
            observer.observe(document, { childList: true, subtree: true });
        }
        
        waitForElement('[data-message-id="\(messageId)"]', function(element) {
            window.stop();
            setTimeout(() => {
                element.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }, 3000);
        });
        """
        
        webView.evaluateJavaScript(script) { _, error in
            if let error = error {
                print("Error executing script: \(error.localizedDescription)")
            }
        }
        
        targetMessageId = nil
    }
    
    func sayChatGPT(_ text: String) {
        guard let jsonData = try? JSONEncoder().encode(text),
              let jsonString = String(data: jsonData, encoding: .utf8)
        else {
            print("Text encoding error")
            return
        }
        
        let script = "document.querySelector('#prompt-textarea').innerText = \(jsonString);"
        webView?.evaluateJavaScript(script) { _, error in
            if let error = error {
                print("Text insertion error: \(error.localizedDescription)")
            }
        }
    }
    
    func scrollToReadAloudElement(at index: Int) {
        let script = """
            (function() {
                var elements = document.querySelectorAll('[aria-label="Read aloud"]');
                if (elements.length > \(index)) {
                    elements[\(index)].scrollIntoView({ behavior: 'smooth', block: 'end' });
                } else {
                    console.error('Index out of bounds: No element at the given index');
                }
            })();
        """
        
        webView?.evaluateJavaScript(script) { _, error in
            if let error = error {
                print("Scroll to element error: \(error.localizedDescription)")
            }
        }
    }
    
    func scrollToNextReadAloudElement() {
        currentReadAloudIndex += 1
        scrollToReadAloudElement(at: currentReadAloudIndex)
    }
    
    func scrollToPreviousReadAloudElement() {
        currentReadAloudIndex = max(0, currentReadAloudIndex - 1)
        scrollToReadAloudElement(at: currentReadAloudIndex)
    }
}
