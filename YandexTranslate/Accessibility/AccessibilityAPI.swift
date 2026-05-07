//
//  Created by Vladislav Librecht on 26.11.2024
//

import ApplicationServices

// sourcery: AutoMockable
protocol AccessibilityAPI {
    func isProcessTrusted() -> Bool
    func isProcessTrusted(with options: CFDictionary?) -> Bool
}

struct Accessibility: AccessibilityAPI {
    func isProcessTrusted() -> Bool {
        if ProcessInfo.processInfo.arguments.contains("test") {
            return ProcessInfo.processInfo.arguments.contains("AXProcessTrusted")
        }
        return AXIsProcessTrusted()
    }
    
    func isProcessTrusted(with options: CFDictionary?) -> Bool {
        if ProcessInfo.processInfo.arguments.contains("test") {
            return ProcessInfo.processInfo.arguments.contains("AXProcessTrustedWithOptions")
        }
        return AXIsProcessTrustedWithOptions(options)
    }
}
