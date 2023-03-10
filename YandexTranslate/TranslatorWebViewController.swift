//  Created by Vladislav Librecht on 06.03.2023.
//

import Cocoa
import WebKit

final class TranslatorWebViewController: NSViewController {
    let contentSize = CGSize(width: 900, height: 650)
    let webView: WKWebView
    
    init() {
        webView = WKWebView(frame: CGRect(origin: .zero, size: contentSize), configuration: WKWebViewConfiguration())
        
        let url = URL(string:"https://translate.yandex.com/?source_lang=en&target_lang=ru")
        let request = URLRequest(url: url!)
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.3 Safari/605.1.15"
        webView.load(request)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let mainView = NSView()
        mainView.setFrameSize(contentSize)
        mainView.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 20),
            webView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
        ])
        view = mainView
    }
    
    func set(textToTranslate text: String) {
        let escapedString = text.unicodeScalars.map { $0.escaped(asASCII: false) }.joined()
        let javascript = """
        var textarea = document.getElementById('textarea');
        textarea.focus();
        textarea.value = '\(escapedString)'
        var event = new Event('input', { bubbles: true });
        textarea.dispatchEvent(event);
        """
        webView.evaluateJavaScript(javascript) { obj, error in
            print("Evaluated: \(String(describing: obj)). Error: \(String(describing: error))")
        }
    }
}
