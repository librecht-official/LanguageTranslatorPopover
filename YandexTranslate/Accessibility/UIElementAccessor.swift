//
//  UIElementAccessor.swift
//  YandexTranslate
//
//  Created by Vladislav Librecht on 06.03.2023.
//

import ApplicationServices

protocol UIElementAccessing {
    subscript(attribute: UIElementAttributeName) -> UIElementAccessing { get throws }
    
    subscript(attribute: UIElementAttributeName, parameter: UIElementAccessing) -> UIElementAccessing { get throws }
    
    subscript(attribute: String) -> UIElementAccessing { get throws }
    
    subscript(attribute: String, parameter: UIElementAccessing) -> UIElementAccessing { get throws }
    
    var element: CFTypeRef { get }
    
    func element<T>(as type: T.Type) throws -> T
    
    func elementAsCGRect() throws -> CGRect
    
    func elementAsArray() throws -> [UIElementAccessing]
}

struct UIElementAccessor: UIElementAccessing {
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
    
    func element<T>(as type: T.Type) throws -> T {
        guard let casted = element as? T else {
            throw TypeCastingError(element, type)
        }
        return casted
    }
    
    func elementAsCGRect() throws -> CGRect {
        var output = CGRect()
        guard CFGetTypeID(element) == AXValueGetTypeID() else {
            throw TypeCastingError(element, CGRect.self)
        }
        AXValueGetValue(element as! AXValue, .cgRect, &output)
        return output
    }
    
    func elementAsArray() throws -> [UIElementAccessing] {
        try element(as: [AXUIElement].self).map(UIElementAccessor.init)
    }
    
    private func asAccessibilityUIElement(_ ref: CFTypeRef) -> AccessibilityUIElement? {
        if CFGetTypeID(ref) == AXUIElementGetTypeID() {
            return ref as! AXUIElement
        }
        if let element = ref as? AccessibilityUIElement {
            return element
        }
        return nil
    }
}

#if DEBUG

extension UIElementAccessing {
    var attributeNames: [String] {
        _attributeNames(element)
    }
    
    var parameterizedAttributeNames: [String] {
        _parameterizedAttributeNames(element)
    }
}

extension AXUIElement {
    var attributeNames: [String] {
        _attributeNames(self)
    }
    
    var parameterizedAttributeNames: [String] {
        _parameterizedAttributeNames(self)
    }
}

func _attributeNames(_ object: CFTypeRef) -> [String] {
    var names: CFArray?
    AXUIElementCopyAttributeNames(object as! AXUIElement, &names)
    return (names as? [String]) ?? []
}

func _parameterizedAttributeNames(_ object: CFTypeRef) -> [String] {
    var names: CFArray?
    AXUIElementCopyParameterizedAttributeNames(object as! AXUIElement, &names)
    return (names as? [String]) ?? []
}

#endif
