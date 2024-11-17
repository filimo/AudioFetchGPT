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
    
    @Published var currentMessageId: String?
    @Published var conversationId: String?
    
    @AppStorage("systemPrompt") var systemPrompt = ""

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
            
            // Добавляем CSS для предотвращения зума
            let css = """
                input, textarea {
                    font-size: 16px !important;
                }
            """
            let jsCSS = """
                var style = document.createElement('style');
                style.innerHTML = `\(css)`;
                document.head.appendChild(style);
            """
            let cssScript = WKUserScript(source: jsCSS, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            webView.configuration.userContentController.addUserScript(cssScript)
            
            // Добавляем JavaScript для фиксации положения элементов
            let focusScript = """
                document.addEventListener('focus', function(event) {
                    setTimeout(function() {
                        event.target.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    }, 1000);
                }, true);
            """
            let focusUserScript = WKUserScript(source: focusScript, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            webView.configuration.userContentController.addUserScript(focusUserScript)
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
        // Преобразуем символы новой строки для корректной интерпретации в JavaScript

        let text = text.replacingOccurrences(of: "`", with: "\\`")
        let script = """
            (function() {
                function setContentEditableText(id, text) {
                    const editor = document.getElementById(id);
                    if (!editor) {
                        console.error(`Element with ID '${id}' not found.`);
                        return;
                    }

                    // Focus on the element
                    editor.focus();

                    // Set the cursor to the end
                    const range = document.createRange();
                    const selection = window.getSelection();

                    range.selectNodeContents(editor);
                    range.collapse(false); // Moves the cursor to the end

                    selection.removeAllRanges();
                    selection.addRange(range);

                    // Insert text
                    document.execCommand('insertText', false, text);

                    // Send the 'input' event
                    const inputEvent = new Event('input', { bubbles: true, cancelable: true });
                    editor.dispatchEvent(inputEvent);
                }

                // Using the function
                setContentEditableText("prompt-textarea", `\(text)`);

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

    func scrollToTopScreen() {
        let script = "document.querySelector('article').scrollIntoView({ behavior: 'smooth', block: 'start' });"
        webView.evaluateJavaScript(script) { _, error in
            if let error = error {
                print("Scroll to top error: \(error.localizedDescription)")
            }
        }
    }

    func scrollToBottomScreen() {
        let script = """
            (function() {
                let lastArticle = document.querySelectorAll('article')[document.querySelectorAll('article').length - 1];
                lastArticle.scrollIntoView({ behavior: 'smooth', block: 'end' });
            })();
        """
        
        webView.evaluateJavaScript(script) { _, error in
            if let error = error {
                print("Scroll to bottom error: \(error.localizedDescription)")
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

    func clickAllVoicePlayTurnActionButtons(downloadedMessageIDs: [String]) {
        let script = """
            (function() {
                let downloadedMessageIDs = \(downloadedMessageIDs);    
                document.querySelectorAll('[data-testid="voice-play-turn-action-button"]').forEach(el => {
                    const messageId = el.closest('article')?.querySelector('[data-message-id]')?.dataset.messageId;

                    if (downloadedMessageIDs.includes(messageId) == false) {
                        el.click();
                    }
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

    func getCurrentConversationId() -> String? {
        guard let url = webView.url else { return nil }
        
        let pattern = "https://chatgpt.com/c/([a-zA-Z0-9-]+)"
        let regex = try? NSRegularExpression(pattern: pattern)
        let nsString = url.absoluteString as NSString
        let results = regex?.matches(in: url.absoluteString, range: NSRange(location: 0, length: nsString.length))
        
        if let match = results?.first {
            return nsString.substring(with: match.range(at: 1))
        }
        
        return nil
    }
    
    func getSelectedText(completion: @escaping (String?) -> Void) {
        let script = """
            (function() {
                let selection = window.getSelection();
                let text = selection ? selection.toString() : '';
                let messageId = selection?.anchorNode?.parentElement?.closest('article')?.querySelector('[data-message-id]')?.dataset?.messageId || '';
                return { text, messageId };
            })()
        """
        
        webView.evaluateJavaScript(script) { result, error in
            if let dict = result as? [String: String] {
                self.currentMessageId = dict["messageId"]
                self.conversationId = self.getCurrentConversationId()
                completion(dict["text"])
            } else {
                completion(nil)
            }
        }
    }
}
