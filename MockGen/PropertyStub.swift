//
//  Stubbing.swift
//  YobaSwitcherTests
//
//  Created by Vladislav Librecht on 10.01.2023.
//

import XCTest

/// Object that is used to stub a property of a mock
///
/// Allows to set property value before the test and check (assert) recorded information about calls after the test.
public final class PropertyStub<Value> {
    
    // MARK: Configuration
    
    /// Value of the stubbed property
    ///
    /// Getting or setting this value does not affect `getCallCount`/`setCallCount`. However each set saves passed value in `stubValuesHistory`.
    public var stubValue: Value? {
        get {
            stubValuesHistory.last ?? nil
        }
        set {
            stubValuesHistory.append(newValue)
        }
    }
    
    // MARK: Recorded calls
    
    /// Array of recorded values
    public private(set) var stubValuesHistory: [Value?] = []
    public private(set) var getCallCount: Int = 0
    public private(set) var setCallCount: Int = 0
    
    public func reset() {
        stubValuesHistory = []
        getCallCount = 0
        setCallCount = 0
    }
    
    // MARK: Accessors
    
    /// Value accessor
    ///
    /// Affects `getCallCount`, `setCallCount` and `stubValuesHistory`. Should be used only within mock.
    var _value: Value {
        get {
            guard let val = stubValue else {
                testCase?.continueAfterFailure = false
                XCTFail("Uninitialized property getter (\(name)) was called.")
                fatalError()
            }
            getCallCount += 1
            return val
        }
        set {
            setCallCount += 1
            stubValue = newValue
        }
    }
    
    /// Value accessor
    ///
    /// Affects `getCallCount`, `setCallCount` and `stubValuesHistory`. Should be used only within mock.
    var _optionalValue: Value? {
        get {
            getCallCount += 1
            return stubValue
        }
        set {
            setCallCount += 1
            stubValue = newValue
        }
    }
    
    private let name: StaticString
    private weak var testCase: XCTestCase?
    
    public init(name: StaticString, _ testCase: XCTestCase?) {
        self.name = name
        self.testCase = testCase
    }
}

// MARK: - Asserting

extension PropertyStub {
    @discardableResult
    func wasGot(_ expectedCallCount: Int, file: StaticString = #filePath, line: UInt = #line) -> Self {
        XCTAssertEqual(getCallCount, expectedCallCount, "Property \(name) was got \(getCallCount) times, expected: \(expectedCallCount)", file: file, line: line)
        return self
    }
    
    @discardableResult
    func wasSet(_ expectedCallCount: Int, file: StaticString = #filePath, line: UInt = #line) -> Self {
        XCTAssertEqual(setCallCount, expectedCallCount, "Property \(name) was set \(setCallCount) times, expected: \(expectedCallCount)", file: file, line: line)
        return self
    }
    
    @discardableResult
    func equalTo(_ expectedValue: Value, file: StaticString = #filePath, line: UInt = #line) -> Self where Value: Equatable {
        XCTAssertEqual(stubValue, expectedValue, "Property \(name) value is not equal to expected", file: file, line: line)
        return self
    }
    
    @discardableResult
    func identicalTo(_ expectedValue: Value, file: StaticString = #filePath, line: UInt = #line) -> Self where Value: AnyObject {
        XCTAssertIdentical(stubValue, expectedValue, "Property \(name) value is not identical to expected", file: file, line: line)
        return self
    }
}
