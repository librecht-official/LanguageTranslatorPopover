//  Created by Vladislav Librecht on 05.03.2023.
//

import Cocoa

class OnboardingViewController: NSViewController {
    @IBOutlet var messageLabel: NSTextField!
    let translationActivator = TranslationActivator()
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as CFString: true] as CFDictionary
        if AXIsProcessTrustedWithOptions(options) {
            messageLabel.stringValue = "All's good. Select text in any application and press ⌃Z hotkey. You can close this window."
            translationActivator.start()
        } else {
            messageLabel.stringValue = "Accessibility is not allowed for this app. To use this app go to\nSystem Preferences > Security & Privacy > Privacy tab > Accessibility.\nSelect checkbox for “Yandex Translate“."
            timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
                self?.relaunchIfProcessTrusted()
            }
        }
    }
    
    private func relaunchIfProcessTrusted() {
        if AXIsProcessTrusted() {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: Bundle.main.executablePath!)
            try? process.run()
            NSApplication.shared.terminate(self)
        }
    }
}
