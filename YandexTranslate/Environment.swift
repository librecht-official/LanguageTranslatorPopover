//
//  Created by Vladislav Librecht on 16.11.2024
//

import Foundation

// TODO: Delete?
enum Environment {
    static var isTest: Bool {
        if let result = _isTest {
            return result
        }
        let isRunningUnitTests = NSClassFromString("XCTest") != nil
        let result = isRunningUnitTests || ProcessInfo.processInfo.arguments.contains("test")
        _isTest = result
        return result
    }
    private static var _isTest: Bool?
}
