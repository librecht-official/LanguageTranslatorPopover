//
//  UIElementAccessor.swift
//  YandexTranslate
//
//  Created by Vladislav Librecht on 06.03.2023.
//

import Cocoa

protocol UIElementAccessing {
    subscript(attribute: UIElementAttributeName) -> UIElementAccessing { get throws }
    
    subscript(attribute: UIElementAttributeName, parameter: UIElementAccessing) -> UIElementAccessing { get throws }
    
    subscript(attribute: String) -> UIElementAccessing { get throws }
    
    subscript(attribute: String, parameter: UIElementAccessing) -> UIElementAccessing { get throws }
    
    var element: CFTypeRef { get }
    
    func elementAsCGRect() throws -> CGRect
    
    func element<T>(as type: T.Type) throws -> T
}

struct UIElementAttributeName {
    let rawValue: String
    
    init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    init(_ value: String) {
        self.rawValue = value
    }
    
    static let focusedUIElement = UIElementAttributeName(kAXFocusedUIElementAttribute)
    static let selectedText = UIElementAttributeName(kAXSelectedTextAttribute)
    static let selectedTextRange = UIElementAttributeName(kAXSelectedTextRangeAttribute)
    static let selectedTextMarkerRange = UIElementAttributeName("AXSelectedTextMarkerRange")
    static let attributedStringForTextMarkerRange = UIElementAttributeName("AXAttributedStringForTextMarkerRange")
    static let boundsForTextMarkerRange = UIElementAttributeName("AXBoundsForTextMarkerRange")
    static let boundsForRange = UIElementAttributeName(kAXBoundsForRangeParameterizedAttribute)
}

final class UIElementAccessor: UIElementAccessing {
    let element: CFTypeRef
    
    init(_ element: CFTypeRef) {
        self.element = element
    }
    
    subscript(attribute: UIElementAttributeName) -> UIElementAccessing {
        get throws {
            try self[attribute.rawValue]
        }
    }
    
    subscript(attribute: UIElementAttributeName, parameter: UIElementAccessing) -> UIElementAccessing {
        get throws {
            try self[attribute.rawValue, parameter]
        }
    }
    
    subscript(attribute: String) -> UIElementAccessing {
        get throws {
            var outputRef: CFTypeRef?
            let result = asAccessibilityUIElement(element)?.copyAttributeValue(attribute, &outputRef)
            if result == .success, let output = outputRef {
                return UIElementAccessor(output)
            }
            throw UIElementAttributeError(result ?? .noValue, for: attribute)
        }
    }
    
    subscript(attribute: String, parameter: UIElementAccessing) -> UIElementAccessing {
        get throws {
            var outputRef: CFTypeRef?
            let result = asAccessibilityUIElement(element)?.copyParameterizedAttributeValue(attribute, parameter.element, &outputRef)
            if result == .success, let output = outputRef {
                return UIElementAccessor(output)
            }
            throw UIElementAttributeError(result ?? .noValue, for: attribute)
        }
    }
    
    func elementAsCGRect() throws -> CGRect {
        var output = CGRect()
        guard CFGetTypeID(element) == AXValueGetTypeID() else {
            throw TypeCastingError(element, CGRect.self)
        }
        AXValueGetValue(element as! AXValue, .cgRect, &output)
        return output
    }
    
    func element<T>(as type: T.Type) throws -> T {
        guard let casted = element as? T else {
            throw TypeCastingError(element, type)
        }
        return casted
    }
}

private func asAccessibilityUIElement(_ ref: CFTypeRef) -> AccessibilityUIElement? {
    if CFGetTypeID(ref) == AXUIElementGetTypeID() {
        return ref as! AXUIElement
    }
    if let element =  ref as? AccessibilityUIElement {
        return element
    }
    return nil
}

