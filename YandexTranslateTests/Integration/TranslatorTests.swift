//
//  Created by Vladislav Librecht on 27.11.2024
//

import XCTest
import Carbon
import SnapshotTesting
@testable import YandexTranslate

@available(macOS 13.0, *)
@MainActor
final class TranslatorTests: XCTestCase {
    typealias TranslationActivator = _TranslationActivator<GlobalMonitoringMock>
    
    var translationActivator: TranslationActivator!
    var selectedTextExtractorMock: SelectedTextExtractingMock!
    
    override func setUpWithError() throws {
        selectedTextExtractorMock = SelectedTextExtractingMock()
    }

//    override func invokeTest() {
//        withSnapshotTesting(record: .all) {
//            super.invokeTest()
//        }
//    }
    
    func testTranslatorActivationBasics() async throws {
        // Given
        NSApplication.shared.appearance = NSAppearance(named: .aqua)
        
        translationActivator = TranslationActivator(selectedTextExtractors: [selectedTextExtractorMock])
        translationActivator.start()
        
        // Wait for web view to load
        try await Task.sleep(for: .seconds(2))
        
        // 1. Translate given text
        try await activateTranslator()
        
        let popoverContent = try XCTUnwrap(translationActivator.coordinator as? TranslatorViewCoordinator).popoverContent
        assertSnapshot(of: popoverContent, as: .image, named: "1.Initial")
        
        // 2. Scroll down
        popoverContent.webView.scrollToEndOfDocument(nil)
        try await Task.sleep(for: .seconds(1))
        
        assertSnapshot(of: popoverContent, as: .image, named: "2.Scrolled down")
        
        // 3. Activate with new text
        selectedTextExtractorMock.selectedText = "apple"
        try await activateTranslator()
        // - It should translate new text and scroll up automatically
        assertSnapshot(of: popoverContent, as: .image, named: "3.New text")
    }
    
    func activateTranslator() async throws {
        let sendEvent = GlobalMonitoringMock._addGlobalMonitorForEvents.arguments?.1
        let ctrlZ = NSEvent(cgEvent: CGEvent.key(kVK_ANSI_Z, down: true, .maskControl)!)!
        sendEvent?(ctrlZ)
        try await Task.sleep(for: .seconds(2))
    }
}

final class SelectedTextExtractingMock: SelectedTextExtracting {
    var selectedText: String = "text for testing"
    
    func selectedTextInfo() async throws -> SelectedTextInfo {
        SelectedTextInfo(text: selectedText, textFrame: nil)
    }
}

func Context<Result>(_ description: String, block: () throws -> Result) rethrows -> Result {
    try XCTContext.runActivity(named: description, block: { a in try block() })
}

