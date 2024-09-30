import WebKit

final class WebViewNavigationDelegate: NSObject, WKNavigationDelegate {
    weak var viewModel: WebViewModel?
    
    init(viewModel: WebViewModel) {
        self.viewModel = viewModel
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        viewModel?.gotoMessage()
    }
}
