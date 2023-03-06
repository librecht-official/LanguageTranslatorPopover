//
//  AccessibilityErrors.swift
//  YandexTranslate
//
//  Created by Vladislav Librecht on 06.03.2023.
//

import Cocoa

struct UIElementAttributeError: LocalizedError {
    let axError: AXError
    let requestedAttribute: String
    
    init(_ axError: AXError, for requestedAttribute: String) {
        self.axError = axError
        self.requestedAttribute = requestedAttribute
    }
    
    var errorDescription: String? {
        "Failed to get \(requestedAttribute) attribute. Error: \(axError)"
    }
}

extension AXError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .cannotComplete: return "cannotComplete"
        case .noValue: return "noValue"
        default: return String.init(reflecting: self)
        }
    }
}

struct TypeCastingError: LocalizedError {
    let message: String
    
    init<T>(_ object: AnyObject, _ type: T.Type) {
        self.message = "Object \(object) cannot be casted to \(type) type"
    }
    
    var errorDescription: String? { message }
}

struct TextError: LocalizedError {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    var errorDescription: String? { message }
}
