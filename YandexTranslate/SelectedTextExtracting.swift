//  Created by Vladislav Librecht on 07.03.2023.
//

import Cocoa
import Carbon

protocol SelectedTextExtracting {
    func selectedTextInfo() async throws -> SelectedTextInfo
}

struct SelectedTextInfo: Equatable {
    let text: String
    let textFrame: CGRect?
}

// MARK: - Using Accessibility

struct AccessibilityBasedSelectedTextExtractor: SelectedTextExtracting {
    let systemWide: UIElementAccessing
    
    init(systemWide: UIElementAccessing = UIElementAccessor(AXUIElementCreateSystemWide())) {
        self.systemWide = systemWide
    }
    
    func selectedTextInfo() async throws -> SelectedTextInfo {
        let focusedElement = try systemWide[.focusedUIElement]
        // Works for applications that displays HTML like Safari and Mail
        if let range = try? focusedElement[.selectedTextMarkerRange] {
            let selectedText = try focusedElement[.attributedStringForTextMarkerRange, range].element(as: NSAttributedString.self)
            let textFrame = try? focusedElement[.boundsForTextMarkerRange, range].elementAsCGRect()
            
            return SelectedTextInfo(text: selectedText.string, textFrame: textFrame)
        }
        // Works for applications with native UI like Notes, Xcode, etc
        else if let range = try? focusedElement[.selectedTextRange] {
            let selectedText = try focusedElement[.selectedText].element(as: String.self)
            let textFrame = try? focusedElement[.boundsForRange, range].elementAsCGRect()
            
            return SelectedTextInfo(text: selectedText, textFrame: textFrame)
        }
        throw TextError("Got focused element, but failed to get selected text")
    }
}

// MARK: - Using Cmd+C & Pasteboard

// Works for application with non-accessable UI (e.g. electron-based) Visual Studio Code and Sublime Text
struct PasteboardBasedSelectedTextExtractor: SelectedTextExtracting {
    let pasteboard: NSPasteboardProtocol
    
    init(pasteboard: NSPasteboardProtocol = NSPasteboard.general) {
        self.pasteboard = pasteboard
    }
    
    func selectedTextInfo() async throws -> SelectedTextInfo {
        let originalData = pasteboard.data(forType: .string)

        performCopyShortcut()
        try await Task.sleep(nanoseconds: 100_000_000)
        let result = pasteboard.string(forType: .string)

        pasteboard.prepareForNewContents()
        pasteboard.setData(originalData, forType: .string)
        
        if let result = result {
            return SelectedTextInfo(text: result, textFrame: nil)
        }
        throw TextError("Failed to get selected text with pasteboard")
    }
    
    private func performCopyShortcut() {
        let cmdC = [
            key(kVK_Command, .down, .maskCommand),
            key(kVK_ANSI_C, .down, .maskCommand),
            key(kVK_ANSI_C, .up, .maskCommand),
            key(kVK_Command, .up, []),
        ]
        cmdC.forEach { event in
            event?.post(tap: .cghidEventTap)
        }
    }
    
    private enum KeystrokeDirection {
        case up, down
    }
    
    private func key(_ keyCode: Int, _ direction: KeystrokeDirection, _ flags: CGEventFlags) -> CGEvent? {
        let event = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keyCode), keyDown: direction == .down)
        event?.flags = flags
        return event
    }
}
