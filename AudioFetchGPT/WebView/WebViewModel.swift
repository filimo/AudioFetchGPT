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

    private var navigationDelegate: WebViewNavigationDelegate?

    private var targetMessageId: String?

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

    func configureWebView(url: URL) {
        guard let webView = webView else { return }

        // Loading JavaScript script
        let jsScript = try! String(contentsOf: Bundle.main.url(forResource: "script", withExtension: "js")!, encoding: .utf8)

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
                    print("Search error: \(error.localizedDescription)")
                }
            }
        }
    }

    // Asynchronous execution of JavaScript in WebView.
    // This is necessary to perform searches without blocking the user interface.
    // The closure is used to handle results or errors after the search is completed.

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
                behavior: 'smooth', // Smooth scrolling
                block: 'start'      // Scroll so that the element is at the beginning of the visible area
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

        // JavaScript for waiting for the element to appear and scrolling to it
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
            // Interrupt current scrolling
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

        // Reset target messageId
        targetMessageId = nil
    }

    func sayChatGPT(_ text: String) {
        guard let jsonData = try? JSONEncoder().encode(text),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
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
}
