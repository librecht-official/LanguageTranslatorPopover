//
//  AccessibilityUIElement.swift
//  YandexTranslate
//
//  Created by Vladislav Librecht on 06.03.2023.
//

import ApplicationServices

// sourcery: AutoMockable
protocol AccessibilityUIElement {
//    static var systemWide: AccessibilityUIElement { get }
    
    @discardableResult
    func copyAttributeValue(_ attribute: String, _ output: UnsafeMutablePointer<CFTypeRef?>) -> AXError
    
    @discardableResult
    func copyParameterizedAttributeValue(_ attribute: String, _ parameter: CFTypeRef, _ output: UnsafeMutablePointer<CFTypeRef?>) -> AXError
    
    @discardableResult
    func isAttributeSettable(_ attribute: String, _ settable: UnsafeMutablePointer<DarwinBoolean>) -> AXError
    
    @discardableResult
    func setAttributeValue(_ attribute: String, _ output: CFTypeRef) -> AXError
}

extension AXUIElement: AccessibilityUIElement {
//    static var systemWide: AccessibilityUIElement {
//        AXUIElementCreateSystemWide()
//    }
    
    @discardableResult
    func copyAttributeValue(_ attribute: String, _ output: UnsafeMutablePointer<CFTypeRef?>) -> AXError {
        AXUIElementCopyAttributeValue(self, attribute as CFString, output)
    }
    
    @discardableResult
    func copyParameterizedAttributeValue(_ attribute: String, _ parameter: CFTypeRef, _ output: UnsafeMutablePointer<CFTypeRef?>) -> AXError {
        AXUIElementCopyParameterizedAttributeValue(self, attribute as CFString, parameter, output)
    }
    
    @discardableResult
    func isAttributeSettable(_ attribute: String, _ settable: UnsafeMutablePointer<DarwinBoolean>) -> AXError {
        AXUIElementIsAttributeSettable(self, attribute as CFString, settable)
    }
    
    @discardableResult
    func setAttributeValue(_ attribute: String, _ output: CFTypeRef) -> AXError {
        AXUIElementSetAttributeValue(self, attribute as CFString, output)
    }
}
