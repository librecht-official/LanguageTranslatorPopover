//  Created by Vladislav Librecht on 06.03.2023.
//

import Cocoa
import WebKit
import Carbon

final class TranslatorWebViewController: NSViewController {
    let contentSize = CGSize(width: 900, height: 650)
    let webView: WKWebView
    
    init() {
        let webViewFrame = CGRect(origin: .zero, size: contentSize)
        
        let config = WKWebViewConfiguration()
        scope {
            let scriptCode = """
            var el = document.getElementById('header'); if (el) el.parentNode.removeChild(el);
            el = document.getElementById('side-block'); if (el) el.parentNode.removeChild(el);
            el = document.getElementById('verticalMenu'); if (el) el.parentNode.removeChild(el);
            """
            let script = WKUserScript(source: scriptCode, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            config.userContentController.addUserScript(script)
        }
        webView = WKWebView(frame: webViewFrame, configuration: config)
        
        let url = URL(string:"https://translate.yandex.com/?source_lang=en&target_lang=ru")
        let request = URLRequest(url: url!)
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1 Safari/605.1.15" // Safari
        webView.load(request)
        
        super.init(nibName: nil, bundle: nil)
        
        reloadTimer.activate()
        
        webView.uiDelegate = self
    }
    
    private lazy var reloadTimer: DispatchSourceTimer = {
        let timer = DI(DispatchSource.makeTimerSource())
        let reloadInterval = DispatchTimeInterval.seconds(60 * 60 * 24)
        timer.schedule(deadline: .now() + reloadInterval, repeating: reloadInterval, leeway: .seconds(60))
        timer.setEventHandler { [weak self] in
            print("Reload web page at: \(Date())")
            self?.webView.reload()
        }
        return timer
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let mainView = NSView()
        mainView.setFrameSize(contentSize)
        scope {
            mainView.addSubview(webView)
            webView.translatesAutoresizingMaskIntoConstraints = false
            
            let top = webView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 20)
            let bottom = webView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor)
            let leading = webView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor)
            let trailing = webView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor)
            NSLayoutConstraint.activate([top, bottom, leading, trailing])
        }
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
        webView.evaluateJavaScript(javascript) { [weak self] obj, error in
            print("JS code evaluation result: \(String(describing: obj)). Error: \(String(describing: error))")
            self?.webView.scrollToBeginningOfDocument(nil)
        }
    }
}

extension TranslatorWebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, decideMediaCapturePermissionsFor origin: WKSecurityOrigin, initiatedBy frame: WKFrameInfo, type: WKMediaCaptureType) async -> WKPermissionDecision {
        return type == .microphone ? .grant : .prompt
    }
}
