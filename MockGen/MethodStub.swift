//
//  MethodStub.swift
//  YobaSwitcherTests
//
//  Created by Vladislav Librecht on 13.01.2023.
//

import XCTest

/// Object that is used to stub a method of a mock
///
/// Allows to configure method behavior before the test and check (assert) recorded information about calls after the test.
public final class MethodStub<Arguments, ReturnValue> {
    
    // MARK: Configuration
    
    /// Value that the method should return
    ///
    /// If `body` is set this property is ignored.
    public var returnValue: ReturnValue?
    
    /// Error that the method throws
    ///
    /// If `body` is set this property is ignored.
    public var errorToThrow: Error?
    
    /// Custom implementation of the method as a closure
    ///
    /// The value returned by this closure has a priority over the value of `returnValue` property. Similarly the error thrown by this closure has a priority over the value of `errorToThrow` property
    public var body: ((Arguments) throws -> ReturnValue)?
    
    // MARK: Recorded calls
    
    /// Array of all received arguments
    public private(set) var argumentsHistory: [Arguments] = []
    
    /// Last received arguments
    public var arguments: Arguments? {
        argumentsHistory.last
    }
    
    /// Number of times the method was called
    public private(set) var callCount: Int = 0
    
    /// Logger for method calls
    private weak var callLogger: CallLogger?
    
    public func reset() {
        argumentsHistory = []
        callCount = 0
    }
    
    private let name: StaticString
    private weak var testCase: XCTestCase?
    
    public init(name: StaticString, _ testCase: XCTestCase?) {
        self.name = name
        self.testCase = testCase
    }
}

// MARK: - Call logging

public extension MethodStub {
    @discardableResult
    func addLogger(_ logger: CallLogger) -> Self {
        callLogger = logger
        return self
    }
}

// MARK: - Asserting
// This functions should be used to compare recorded state with expected values

public extension MethodStub {
    @discardableResult
    func wasCalled(_ expectedCallCount: Int, file: StaticString = #filePath, line: UInt = #line) -> Self {
        XCTAssertEqual(callCount, expectedCallCount, "Method \(name) was called \(callCount) times, expected: \(expectedCallCount)", file: file, line: line)
        return self
    }
    
    @discardableResult
    func wasCalled(_ expectedCallCount: Int, withArguments expectedArguments: Arguments, file: StaticString = #filePath, line: UInt = #line) -> Self where Arguments: Equatable {
        XCTAssertEqual(callCount, expectedCallCount, "Method \(name) was called \(callCount) times, expected: \(expectedCallCount)", file: file, line: line)
        if let arguments = arguments {
            XCTAssertEqual(arguments, expectedArguments, file: file, line: line)
        } else {
            XCTFail("Method \(name) wasn't called as expected", file: file, line: line)
        }
        return self
    }
    
    @discardableResult
    func wasCalled(_ expectedCallCount: Int, withArguments expectedArguments: [Arguments], file: StaticString = #filePath, line: UInt = #line) -> Self where Arguments: Equatable {
        XCTAssertEqual(callCount, expectedCallCount, "Method \(name) was called \(callCount) times, expected: \(expectedCallCount)", file: file, line: line)
        XCTAssertEqual(argumentsHistory, expectedArguments, file: file, line: line)
        return self
    }
    
    @discardableResult
    func wasCalled(_ expectedCallCount: Int, withArguments argumentsAssertions: (Arguments) -> (), file: StaticString = #filePath, line: UInt = #line) -> Self {
        XCTAssertEqual(callCount, expectedCallCount, "Method \(name) was called \(callCount) times, expected: \(expectedCallCount)", file: file, line: line)
        if let arguments = arguments {
            argumentsAssertions(arguments)
        } else {
            XCTFail("Method \(name) wasn't called as expected", file: file, line: line)
        }
        return self
    }
}

// MARK: - Calls
// This functions should be used only within mocks implementaion

public extension MethodStub {
    func callWith(arguments: Arguments) {
        registerCall(with: arguments)
        
        do {
            _ = try body?(arguments)
        } catch {}
    }
    
    func callWithReturnValue(arguments: Arguments, filePath: StaticString = #filePath, line: UInt = #line) -> ReturnValue {
        registerCall(with: arguments)
        
        var returnedValue: ReturnValue?
        do {
            returnedValue = try body?(arguments)
        } catch {}
        
        guard let result = returnedValue ?? returnValue else {
            testCase?.continueAfterFailure = false
            XCTFail("Method `\(name)` was called with uninitialized return-value", file: filePath, line: line)
            fatalError()
        }
        
        return result
    }
    
    func callWithOptionalReturnValue(arguments: Arguments) -> ReturnValue? {
        registerCall(with: arguments)
        
        var returnedValue: ReturnValue?
        do {
            returnedValue = try body?(arguments)
        } catch {}
        
        return returnedValue ?? returnValue
    }
    
    func callWithThrow(arguments: Arguments) throws {
        registerCall(with: arguments)
        
        if let body = body {
            _ = try body(arguments)
        } else if let error = errorToThrow {
            throw error
        }
    }
    
    func callWithThrowReturnValue(arguments: Arguments, filePath: StaticString = #filePath, line: UInt = #line) throws -> ReturnValue {
        registerCall(with: arguments)
        
        var returnedValue: ReturnValue?
        
        if let body = body {
            returnedValue = try body(arguments)
        } else if let error = errorToThrow {
            throw error
        }
        
        guard let result = returnedValue ?? returnValue else {
            testCase?.continueAfterFailure = false
            XCTFail("Method `\(name)` was called with uninitialized return-value", file: filePath, line: line)
            fatalError()
        }
        
        return result
    }
    
    func callWithThrowOptionalReturnValue(arguments: Arguments) throws -> ReturnValue? {
        registerCall(with: arguments)
        
        var returnedValue: ReturnValue?
        
        if let body = body {
            returnedValue = try body(arguments)
        } else if let error = errorToThrow {
            throw error
        }
        
        return returnedValue ?? returnValue
    }
    
    private func registerCall(with arguments: Arguments) {
        callCount += 1
        argumentsHistory.append(arguments)
        callLogger?.log(function: name, arguments)
    }
}
