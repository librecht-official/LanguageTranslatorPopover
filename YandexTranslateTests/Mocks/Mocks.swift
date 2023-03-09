// Generated using Sourcery 1.6.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable line_length
// swiftlint:disable variable_name

import XCTest
@testable import YandexTranslate

open class AccessibilityUIElementMock: AccessibilityUIElement {
    public let _mockId: String?
    public static weak var testCase: XCTestCase?
    public private(set) weak var testCase: XCTestCase?

    public init(_ testCase: XCTestCase, id: String? = nil) {
        self.testCase = testCase
        self._mockId = id
    }

    // MARK: copyAttributeValue(_:_:)
    // annotations: [:]
    public private(set) lazy var _copyAttributeValue = MethodStub<(String, UnsafeMutablePointer<CFTypeRef?>), AXError>(name: "copyAttributeValue(_:_:)", testCase)

    @discardableResult
    public func copyAttributeValue(_ attribute: String, _ output: UnsafeMutablePointer<CFTypeRef?>) -> AXError {
        _copyAttributeValue.callWithReturnValue(arguments: (attribute, output))
    }

    // MARK: copyParameterizedAttributeValue(_:_:_:)
    // annotations: [:]
    public private(set) lazy var _copyParameterizedAttributeValue = MethodStub<(String, CFTypeRef, UnsafeMutablePointer<CFTypeRef?>), AXError>(name: "copyParameterizedAttributeValue(_:_:_:)", testCase)

    @discardableResult
    public func copyParameterizedAttributeValue(_ attribute: String, _ parameter: CFTypeRef, _ output: UnsafeMutablePointer<CFTypeRef?>) -> AXError {
        _copyParameterizedAttributeValue.callWithReturnValue(arguments: (attribute, parameter, output))
    }

    // MARK: isAttributeSettable(_:_:)
    // annotations: [:]
    public private(set) lazy var _isAttributeSettable = MethodStub<(String, UnsafeMutablePointer<DarwinBoolean>), AXError>(name: "isAttributeSettable(_:_:)", testCase)

    @discardableResult
    public func isAttributeSettable(_ attribute: String, _ settable: UnsafeMutablePointer<DarwinBoolean>) -> AXError {
        _isAttributeSettable.callWithReturnValue(arguments: (attribute, settable))
    }

    // MARK: setAttributeValue(_:_:)
    // annotations: [:]
    public private(set) lazy var _setAttributeValue = MethodStub<(String, CFTypeRef), AXError>(name: "setAttributeValue(_:_:)", testCase)

    @discardableResult
    public func setAttributeValue(_ attribute: String, _ output: CFTypeRef) -> AXError {
        _setAttributeValue.callWithReturnValue(arguments: (attribute, output))
    }

    static func resetState() {
    }
}

// MARK: -

open class NSPasteboardMock: NSPasteboardProtocol {
    public let _mockId: String?
    public static weak var testCase: XCTestCase?
    public private(set) weak var testCase: XCTestCase?

    public init(_ testCase: XCTestCase, id: String? = nil) {
        self.testCase = testCase
        self._mockId = id
    }

    // MARK: data(forType:)
    // annotations: ["stubName": dataForType]
    public private(set) lazy var _dataForType = MethodStub<NSPasteboard.PasteboardType, Data>(name: "data(forType:)", testCase)

    public func data(forType dataType: NSPasteboard.PasteboardType) -> Data? {
        _dataForType.callWithOptionalReturnValue(arguments: dataType)
    }

    // MARK: string(forType:)
    // annotations: ["stubName": stringForType]
    public private(set) lazy var _stringForType = MethodStub<NSPasteboard.PasteboardType, String>(name: "string(forType:)", testCase)

    public func string(forType dataType: NSPasteboard.PasteboardType) -> String? {
        _stringForType.callWithOptionalReturnValue(arguments: dataType)
    }

    // MARK: prepareForNewContents
    // annotations: [:]
    public private(set) lazy var _prepareForNewContents = MethodStub<(), Int>(name: "prepareForNewContents", testCase)

    @discardableResult
    public func prepareForNewContents() -> Int {
        _prepareForNewContents.callWithReturnValue(arguments: ())
    }

    // MARK: setData(_:forType:)
    // annotations: ["stubName": setDataForType]
    public private(set) lazy var _setDataForType = MethodStub<(Data?, NSPasteboard.PasteboardType), Bool>(name: "setData(_:forType:)", testCase)

    @discardableResult
    public func setData(_ data: Data?, forType dataType: NSPasteboard.PasteboardType) -> Bool {
        _setDataForType.callWithReturnValue(arguments: (data, dataType))
    }

    static func resetState() {
    }
}

// MARK: -

open class SystemEventMock: SystemEvent {
    public let _mockId: String?
    public static weak var testCase: XCTestCase?
    public private(set) weak var testCase: XCTestCase?

    public init(_ testCase: XCTestCase, id: String? = nil) {
        self.testCase = testCase
        self._mockId = id
    }

    // MARK: key(_:down:_:)
    // annotations: [:]
    public private(set) static var _keyDown = MethodStub<(Int, Bool, CGEventFlags), SystemEventMock>(name: "key(_:down:_:)", testCase)

    public static func key(_ keyCode: Int, down: Bool, _ flags: CGEventFlags) -> Self? {
        _keyDown.callWithOptionalReturnValue(arguments: (keyCode, down, flags)) as? Self
    }

    // MARK: post(tap:)
    // annotations: [:]
    public private(set) lazy var _postTap = MethodStub<CGEventTapLocation, Void>(name: "post(tap:)", testCase)

    public func post(tap: CGEventTapLocation) -> Void {
        _postTap.callWith(arguments: tap)
    }

    static func resetState() {
        _keyDown.reset()
    }
}

// MARK: -

open class SystemEventDispatchingMock: SystemEventDispatching {
    public let _mockId: String?
    public static weak var testCase: XCTestCase?
    public private(set) weak var testCase: XCTestCase?

    public init(_ testCase: XCTestCase, id: String? = nil) {
        self.testCase = testCase
        self._mockId = id
    }

    // MARK: post(event:tap:)
    // annotations: [:]
    public private(set) lazy var _postEventTap = MethodStub<(Any?, CGEventTapLocation), Void>(name: "post(event:tap:)", testCase)

    public func post<Event: SystemEvent>(event: Event?, tap: CGEventTapLocation) -> Void {
        _postEventTap.callWith(arguments: (event, tap))
    }

    static func resetState() {
    }
}

// MARK: -

open class TaskMock: TaskProtocol {
    public let _mockId: String?
    public static weak var testCase: XCTestCase?
    public private(set) weak var testCase: XCTestCase?

    public init(_ testCase: XCTestCase, id: String? = nil) {
        self.testCase = testCase
        self._mockId = id
    }

    // MARK: sleep(nanoseconds:)
    // annotations: [:]
    public private(set) static var _sleepNanoseconds = MethodStub<UInt64, Void>(name: "sleep(nanoseconds:)", testCase)

    public static func sleep(nanoseconds: UInt64) throws -> Void {
        try _sleepNanoseconds.callWithThrow(arguments: nanoseconds)
    }

    static func resetState() {
        _sleepNanoseconds.reset()
    }
}

// MARK: -

open class UIElementAccessingMock: UIElementAccessing {
    public let _mockId: String?
    public static weak var testCase: XCTestCase?
    public private(set) weak var testCase: XCTestCase?

    public init(_ testCase: XCTestCase, id: String? = nil) {
        self.testCase = testCase
        self._mockId = id
    }

    // MARK: element
    // annotations: [:]
    public private(set) lazy var _element = PropertyStub<CFTypeRef>(name: "element", testCase)

    public var element: CFTypeRef {
        _element._value
    }

    // MARK: attributeNames
    // annotations: [:]
    public private(set) lazy var _attributeNames = PropertyStub<[String]>(name: "attributeNames", testCase)

    public var attributeNames: [String] {
        _attributeNames._value
    }

    // MARK: parameterizedAttributeNames
    // annotations: [:]
    public private(set) lazy var _parameterizedAttributeNames = PropertyStub<[String]>(name: "parameterizedAttributeNames", testCase)

    public var parameterizedAttributeNames: [String] {
        _parameterizedAttributeNames._value
    }

    // MARK: element(as:)
    // annotations: [:]
    public private(set) lazy var _elementAsType = MethodStub<Any, Any>(name: "element(as:)", testCase)

    public func element<T>(as type: T.Type) throws -> T {
        try _elementAsType.callWithThrowReturnValue(arguments: type) as! T
    }

    // MARK: elementAsCGRect
    // annotations: [:]
    public private(set) lazy var _elementAsCGRect = MethodStub<(), CGRect>(name: "elementAsCGRect", testCase)

    public func elementAsCGRect() throws -> CGRect {
        try _elementAsCGRect.callWithThrowReturnValue(arguments: ())
    }

    // MARK: elementAsArray
    // annotations: [:]
    public private(set) lazy var _elementAsArray = MethodStub<(), [UIElementAccessing]>(name: "elementAsArray", testCase)

    public func elementAsArray() throws -> [UIElementAccessing] {
        try _elementAsArray.callWithThrowReturnValue(arguments: ())
    }
    
    // annotations: ["throws": 1]
    public private(set) lazy var _subscriptGetAttribute = MethodStub<String, UIElementAccessing>(name: "get[attribute:]", testCase)
    
    public subscript(attribute: String) -> UIElementAccessing {
        get throws {
            try _subscriptGetAttribute.callWithThrowReturnValue(arguments: attribute)
        }
    }
    
    // annotations: ["throws": 1]
    public private(set) lazy var _subscriptGetAttributeParameter = MethodStub<(String, UIElementAccessing), UIElementAccessing>(name: "get[attribute:, parameter:]", testCase)
    
    public subscript(attribute: String, parameter: UIElementAccessing) -> UIElementAccessing {
        get throws {
            try _subscriptGetAttributeParameter.callWithThrowReturnValue(arguments: (attribute, parameter))
        }
    }

    static func resetState() {
    }
}

// MARK: -
