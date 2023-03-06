//
//  TranslationActivator.swift
//  YandexTranslate
//
//  Created by Vladislav Librecht on 06.03.2023.
//

import AppKit
import Carbon

final class TranslationActivator<Monitor: GlobalMonitoring> {
    let systemWide: UIElementAccessing
    
    init(systemWide: UIElementAccessing = UIElementAccessor(AXUIElementCreateSystemWide())) {
        self.systemWide = systemWide
    }
    
    func start() {
        Monitor.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == kVK_ANSI_Grave && event.modifierFlags.contains(.control) {
                self?.findSelectedTextAndRunTranslator()
            }
        }
    }
    
    private func findSelectedTextAndRunTranslator() {
        do {
            let (selectedText, textFrame) = try findSelectedText()
            print("Selected text: \(selectedText), frame: \(textFrame)")
//            coordinator.presentTranslationPopover(text: selectedText, textFrame: textFrame)
        }
        catch {
            print(error)
        }
    }
    
    private func findSelectedText() throws -> (String, CGRect) {
        let focusedElement = try systemWide[.focusedUIElement]
        
        if let range = try? focusedElement[.selectedTextMarkerRange] {
            let selectedText = try focusedElement[.attributedStringForTextMarkerRange, range].element(as: NSAttributedString.self)
            let textFrame = try focusedElement[.boundsForTextMarkerRange, range].elementAsCGRect()
            
            return (selectedText.string, textFrame)
        }
        else if let range = try? focusedElement[.selectedTextRange] {
            let selectedText = try focusedElement[.selectedText].element(as: String.self)
            let textFrame = try focusedElement[.boundsForRange, range].elementAsCGRect()
            
            return (selectedText, textFrame)
        }
        else {
            throw TextError("Failed to get selected text")
        }
    }
}
