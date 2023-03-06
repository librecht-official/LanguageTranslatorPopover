//
//  UIElementAttributeName.swift
//  YandexTranslate
//
//  Created by Vladislav Librecht on 07.03.2023.
//

import ApplicationServices

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
