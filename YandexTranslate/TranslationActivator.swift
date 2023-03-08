//  Created by Vladislav Librecht on 06.03.2023.
//

import Cocoa
import Carbon

typealias TranslationActivator = _TranslationActivator<NSEvent>

@MainActor
final class _TranslationActivator<Monitor: GlobalMonitoring> {
    let selectedTextExtractors: [SelectedTextExtracting]
    let coordinator: TranslatorViewCoordinating
    
    init(selectedTextExtractors: [SelectedTextExtracting]? = nil, coordinator: TranslatorViewCoordinating = TranslatorViewCoordinator()) {
        self.selectedTextExtractors = selectedTextExtractors ?? [
            AccessibilityBasedSelectedTextExtractor(),
            PasteboardBasedSelectedTextExtractor()
        ]
        self.coordinator = coordinator
    }
    
    func start() {
        Monitor.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.type == .keyDown && event.keyCode == kVK_ANSI_Z/*kVK_ANSI_Grave*/ && event.modifierFlags.contains(.control) {
                Task {
                    await self?.findSelectedTextAndRunTranslator()
                }
            }
        }
    }
    
    private func findSelectedTextAndRunTranslator() async {
        if let info = await findSelectedText() {
            print("Selected text: \(info)")
            coordinator.showPopover(text: info.text, textFrame: info.textFrame)
        }
        else {
            print("No selected text found")
        }
    }
    
    private func findSelectedText() async -> SelectedTextInfo? {
        for extractor in selectedTextExtractors {
            do {
                return try await extractor.selectedTextInfo()
            }
            catch {
                print(error)
            }
        }
        return nil
    }
}
