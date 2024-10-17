//
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 16.09.24.
//

import WebKit
import SwiftUI

final class ConversationNavigationDelegate: NSObject, WKNavigationDelegate {
    weak var viewModel: ConversationWebViewModel?
    
    init(viewModel: ConversationWebViewModel) {
        self.viewModel = viewModel
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        viewModel?.gotoMessage()
        
        // Saving the current URL
        if let currentURL = webView.url?.absoluteString {
            viewModel?.lastVisitedURL = currentURL
        }
    }
}
