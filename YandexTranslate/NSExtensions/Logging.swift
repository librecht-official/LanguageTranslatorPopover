//
//  Created by Vladislav Librecht on 08.05.2026
//

import OSLog

extension Logger {
    init(category: String) {
        self.init(subsystem: Bundle.main.bundleIdentifier ?? "", category: category)
    }
}

extension String.StringInterpolation {
    mutating func appendInterpolation<T>(_ optional: T?) {
        if let value = optional {
            appendInterpolation(value)
        } else {
            appendInterpolation("nil")
        }
    }
}

extension Optional {
    var toString: String {
        if let value = self {
            return "\(value)"
        } else {
            return "nil"
        }
    }
}
