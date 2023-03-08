//
//  Created by Vladislav Librecht on 09.03.2023
//

import XCTest

func AssertThrowsError<T>(_ expression: @autoclosure () async throws -> T, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line, _ errorHandler: (_ error: Error) -> Void = { _ in }) async {
    do {
        _ = try await expression()
        XCTFail("AssertThrowsError failed: did not throw an error - \(message())", file: file, line: line)
    } catch {
        errorHandler(error)
    }
}
