//
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 16.09.24.
//

import SwiftUI
import WebKit

final class ConversationWebViewModel: ObservableObject {
    @Published var webView: WKWebView = .init()
    
    @AppStorage("lastVisitedURL") var lastVisitedURL: String = "https://chatgpt.com"
    
    private var navigationDelegate: ConversationNavigationDelegate?
    private var targetMessageId: String?
    private var currentReadAloudIndex: Int = 0
    
    init() {
        webView.isInspectable = true
        setupNavigationDelegate()
    }
    
    private func setupNavigationDelegate() {
        let delegate = ConversationNavigationDelegate(viewModel: self)
        navigationDelegate = delegate
        webView.navigationDelegate = delegate
    }
    
    func configureWebView() {
        do {
            // Загрузка JavaScript скрипта
            let jsScriptURL = Bundle.main.url(forResource: "conversationScript", withExtension: "js")
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
        webView.reload()
    }
    
    func performSearch(text: String, forward: Bool) {
        guard !text.isEmpty else { return }
        
        let script = "window.find('\(text)', false, \(!forward), true)"
        webView.evaluateJavaScript(script) { _, error in
            if let error = error {
                print("Search error: \(error.localizedDescription)")
            }
        }
    }
    
    func gotoMessage(conversationId: String, messageId: String) {
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
        
        webView.evaluateJavaScript(script) { _, error in
            if let error = error {
                print("Navigation error: \(error.localizedDescription)")
            }
        }
    }
    
    func gotoMessage() {
        guard let messageId = targetMessageId else { return }
        
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
        
        let script = """
            (function() {
                document.querySelector('#prompt-textarea').innerText += \(jsonString);
                setTimeout(() => {
                    document.querySelector('[data-testid="send-button"]').click();
                }, 300);
            })();
        """
        webView.evaluateJavaScript(script) { _, error in
            if let error = error {
                print("Text insertion error: \(error.localizedDescription)")
            }
        }
    }
    
    func scrollToReadAloudElement(at index: Int) {
        let script = """
            (function() {
                var elements = document.querySelectorAll('[data-testid="voice-play-turn-action-button"]');
                if (elements.length > \(index)) {
                    elements[\(index)].scrollIntoView({ behavior: 'smooth', block: 'end' });
                } else {
                    console.error('Index out of bounds: No element at the given index');
                }
            })();            
        """
        
        webView.evaluateJavaScript(script) { _, error in
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

    func clickAllVoicePlayTurnActionButtons() {
        let script = """
            (function() {
                document.querySelectorAll('[data-testid="voice-play-turn-action-button"]').forEach(el => {
                    el.click();
                });
            })();
        """
        
        webView.evaluateJavaScript(script) { _, error in
            if let error = error {
                print("Click all voice play turn action buttons error: \(error.localizedDescription)")
            }
        }
    }

    @MainActor
    func removeProcessedAudioItem(conversationId: String, messageId: String) async throws {
        let script = """
            (function() {
                localStorage.removeItem('\(conversationId)_\(messageId)');
            })();
        """
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            webView.evaluateJavaScript(script) { _, error in
                if let error = error {
                    print("Remove processed audio item error: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}
