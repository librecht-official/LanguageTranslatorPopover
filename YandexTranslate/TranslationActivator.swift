//  Created by Vladislav Librecht on 06.03.2023.
//

import Cocoa
import Carbon
import OSLog

@MainActor
// sourcery: AutoMockable
protocol TranslationActivating {
    func start()
}

typealias TranslationActivator = _TranslationActivator<NSEvent>

@MainActor
final class _TranslationActivator<Monitor: GlobalMonitoring>: TranslationActivating {
    let notificationCenter: NotificationCenter
    let selectedTextExtractors: [SelectedTextExtracting]
    let coordinator: TranslatorViewCoordinating
    let logger = Logger(category: "TranslationActivator")
    
    init(selectedTextExtractors: [SelectedTextExtracting]? = nil, coordinator: TranslatorViewCoordinating? = nil, notificationCenter: NotificationCenter = .default) {
        self.selectedTextExtractors = selectedTextExtractors ?? [
            AccessibilityBasedSelectedTextExtractor(),
            PasteboardBasedSelectedTextExtractor()
        ]
        self.coordinator = coordinator ?? TranslatorViewCoordinator()
        self.notificationCenter = notificationCenter
    }
    
    func start() {
        Monitor.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.type == .keyDown && event.keyCode == kVK_ANSI_Z && event.modifierFlags.contains(.control) {
                self?.findSelectedTextAndRunTranslator()
            }
        }
        notificationCenter.addObserver(self, selector: #selector(showTranslatorView), name: .YTShowTranslatorPopover, object: nil)
    }
    
    @objc private func showTranslatorView() {
        logger.debug("Show translator view from notification")
        coordinator.showPopover(text: "", textFrame: nil)
    }
    
    private func findSelectedTextAndRunTranslator() {
        Task {
            let info = await findSelectedText()
            logger.debug("Selected text: \(info.toString)")
            coordinator.showPopover(text: info?.text ?? "", textFrame: info?.textFrame)
        }
    }
    
    private nonisolated func findSelectedText() async -> SelectedTextInfo? {
        for extractor in await selectedTextExtractors {
            do {
                return try await extractor.selectedTextInfo()
            }
            catch {
                logger.error("Selected text not found: \(error)")
            }
        }
        return nil
    }
}

extension NSNotification.Name {
    static let YTShowTranslatorPopover = NSNotification.Name("YTShowTranslatorPopover")
}
