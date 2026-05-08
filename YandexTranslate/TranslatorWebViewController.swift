//  Created by Vladislav Librecht on 06.03.2023.
//

import Cocoa
import WebKit
import Carbon
import OSLog

final class TranslatorWebViewController: NSViewController {
    let contentSize = CGSize(width: 800, height: 650)
    let webView: WKWebView
    let logger = Logger(category: "TranslatorWebView")
    
    init() {
        let webViewFrame = CGRect(origin: .zero, size: contentSize)
        
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: webViewFrame, configuration: config)
        
        let url = URL(string: "https://translate.yandex.com/?source_lang=en&target_lang=ru")
        let request = URLRequest(url: url!)
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1 Safari/605.1.15" // Safari
        webView.load(request)
        webView.pageZoom = 0.75
        
        super.init(nibName: nil, bundle: nil)
        
        reloadTimer.activate()
        
        webView.navigationDelegate = self
    }
    
    private lazy var reloadTimer: DispatchSourceTimer = {
        let timer = DispatchSource.makeTimerSource()
        let reloadInterval = DispatchTimeInterval.seconds(60 * 60 * 24)
        timer.schedule(deadline: .now() + reloadInterval, repeating: reloadInterval, leeway: .seconds(60))
        timer.setEventHandler { [weak self] in
            self?.logger.debug("Reload web page at: \(Date())")
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
        
        webView.setAccessibilityIdentifier("translator_web_view")
    }
    
    func set(textToTranslate text: String) {
        let escapedString = text.unicodeScalars.map { $0.escaped(asASCII: false) }.joined()
        let javascript = """
        function isVisibleToAccessibility(el) {
          // 1. Проверяем стандартные CSS способы скрытия
          const style = window.getComputedStyle(el);
          if (style.display === 'none' || style.visibility === 'hidden' || style.opacity === '0') {
            return false;
          }

          // 2. Проверяем атрибут aria-hidden (у самого элемента или его родителей)
          if (el.closest('[aria-hidden="true"]')) {
            return false;
          }

          // 3. Проверяем физические размеры (скрытые элементы часто имеют 0x0)
          if (el.offsetWidth === 0 && el.offsetHeight === 0) {
            return false;
          }

          return true;
        }
        
        var textarea = Array.from(document.querySelectorAll(`input, textarea, [role="textbox"]`)).find(isVisibleToAccessibility);
        textarea.focus();
        textarea.value = '\(escapedString)'
        var event = new Event('input', { bubbles: true });
        textarea.dispatchEvent(event);
        """
        logger.debug("Setting text to translate: \(escapedString)")
        
        webView.evaluateJavaScript(javascript) { [weak self] obj, error in
            self?.logJSCodeEvalResult(obj, error)
            self?.webView.scrollToBeginningOfDocument(nil)
        }
    }
}

extension TranslatorWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.absoluteString.contains("translate.yandex.com") {
            decisionHandler(.allow)
        } else {
            decisionHandler(.cancel)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        logger.debug("Tuning web page content and style")
        let javascript = """
        document.getElementById('header')?.remove();
        document.getElementsByClassName('side-block')?.[0]?.remove();
        document.getElementById('verticalMenu')?.remove();
        document.getElementById('gptTutorEntry')?.remove();
        document.getElementById('footer')?.remove();
        
        document.styleSheets[0].insertRule(".page.page_vertical-menu { padding: 0 !important; }");
        
        document.activeElement.id;
        """
        webView.evaluateJavaScript(javascript) { [weak self] obj, error in
            self?.logJSCodeEvalResult(obj, error)
        }
    }
    
    func logJSCodeEvalResult(_ obj: Any?, _ error: Error?, fromFn: StaticString = #function) {
        logger.debug("[\(fromFn)] JS code evaluation result: \(obj.toString). Error: \(error)")
    }
}
