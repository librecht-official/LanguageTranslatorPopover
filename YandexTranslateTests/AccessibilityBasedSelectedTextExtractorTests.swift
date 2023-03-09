//
//  Created by Vladislav Librecht on 08.03.2023
//

import XCTest
@testable import YandexTranslate

@MainActor
final class AccessibilityBasedSelectedTextExtractorTests: XCTestCase {
    var extractor: AccessibilityBasedSelectedTextExtractor!
    var systemWideMock: UIElementAccessingMock!
    var focusedElementMock: UIElementAccessingMock!
    var textMarkerRangeMock: UIElementAccessingMock!
    var textRangeMock: UIElementAccessingMock!
    
    override func setUpWithError() throws {
        systemWideMock = UIElementAccessingMock(self)
        focusedElementMock = UIElementAccessingMock(self)
        textMarkerRangeMock = UIElementAccessingMock(self, id: "textMarkerRange")
        textRangeMock = UIElementAccessingMock(self, id: "textRange")
        extractor = AccessibilityBasedSelectedTextExtractor(systemWide: systemWideMock)
    }
    
    // MARK: - selectedTextInfo

    func testSelectedTextInfo_NoFocusedElement() async throws {
        // given
        systemWideMock._subscriptGetAttribute.errorToThrow = TestData.error
        // then
        await AssertThrowsError(try await extractor.selectedTextInfo())
        systemWideMock._subscriptGetAttribute.wasCalled(1, withArguments: kAXFocusedUIElementAttribute)
    }
    
    func testSelectedTextInfo_NoSelectedTextRange() async throws {
        // given
        systemWideMock._subscriptGetAttribute.returnValue = focusedElementMock
        focusedElementMock._subscriptGetAttribute.errorToThrow = TestData.error
        // then
        await AssertThrowsError(try await extractor.selectedTextInfo())
        systemWideMock._subscriptGetAttribute.wasCalled(1)
        focusedElementMock._subscriptGetAttribute.wasCalled(2, withArguments: ["AXSelectedTextMarkerRange", kAXSelectedTextRangeAttribute])
    }
    
    /// Focused UI element exists; Selected text exists as attributed string; Selected text bounds exists.
    /// Should return selected text with bounds.
    func testSelectedTextInfo_SelectedTextMarkerRange() async throws {
        // given
        systemWideMock._subscriptGetAttribute.returnValue = focusedElementMock
        focusedElementMock._subscriptGetAttribute.body = { attribute in
            switch attribute {
            case "AXSelectedTextMarkerRange": return self.textMarkerRangeMock
            default: throw TestData.error
            }
        }
        focusedElementMock._subscriptGetAttributeParameter.body = { args in
            let (attribute, parameter) = args
            XCTAssertIdentical(parameter as? UIElementAccessingMock, self.textMarkerRangeMock)
            switch attribute {
            case "AXAttributedStringForTextMarkerRange":
                return UIElementAccessor(NSAttributedString(string: "Selected Text"))
            case "AXBoundsForTextMarkerRange":
                var bounds = TestData.textFrame
                return UIElementAccessor(AXValueCreate(.cgRect, &bounds)!)
            default: throw TestData.error
            }
        }
        // when
        let result = try await extractor.selectedTextInfo()
        // then
        systemWideMock._subscriptGetAttribute.wasCalled(1)
        focusedElementMock._subscriptGetAttribute.wasCalled(1, withArguments: "AXSelectedTextMarkerRange")
        focusedElementMock._subscriptGetAttributeParameter.wasCalled(2)
        let argumentsHistory = focusedElementMock._subscriptGetAttributeParameter.argumentsHistory.map { $0.0 }
        XCTAssertEqual(argumentsHistory, ["AXAttributedStringForTextMarkerRange", "AXBoundsForTextMarkerRange"])
        XCTAssertEqual(result, SelectedTextInfo(text: "Selected Text", textFrame: TestData.textFrame))
    }
    
    /// Focused UI element exists; Selected text marker range exists but no selected text; Selected text bounds doesn't exist.
    /// Should throw error.
    func testSelectedTextInfo_SelectedTextMarkerRange_NoSelectedText() async throws {
        // given
        systemWideMock._subscriptGetAttribute.returnValue = focusedElementMock
        focusedElementMock._subscriptGetAttribute.body = { attribute in
            switch attribute {
            case "AXSelectedTextMarkerRange": return self.textMarkerRangeMock
            default: throw TestData.error
            }
        }
        focusedElementMock._subscriptGetAttributeParameter.body = { args in
            let (_, parameter) = args
            XCTAssertIdentical(parameter as? UIElementAccessingMock, self.textMarkerRangeMock)
            throw TestData.error
        }
        // when
        await AssertThrowsError(try await extractor.selectedTextInfo())
        // then
        systemWideMock._subscriptGetAttribute.wasCalled(1)
        focusedElementMock._subscriptGetAttribute.wasCalled(1, withArguments: "AXSelectedTextMarkerRange")
        focusedElementMock._subscriptGetAttributeParameter.wasCalled(1)
        let argumentsHistory = focusedElementMock._subscriptGetAttributeParameter.argumentsHistory.map { $0.0 }
        XCTAssertEqual(argumentsHistory, ["AXAttributedStringForTextMarkerRange"])
    }
    
    /// Focused UI element exists; Selected text marker range exists; Selected text is not an attributed string; Selected text bounds doesn't exist.
    /// Should throw error.
    func testSelectedTextInfo_SelectedTextMarkerRange_WrongSelectedTextType() async throws {
        // given
        systemWideMock._subscriptGetAttribute.returnValue = focusedElementMock
        focusedElementMock._subscriptGetAttribute.body = { attribute in
            switch attribute {
            case "AXSelectedTextMarkerRange": return self.textMarkerRangeMock
            default: throw TestData.error
            }
        }
        focusedElementMock._subscriptGetAttributeParameter.body = { args in
            let (attribute, parameter) = args
            XCTAssertIdentical(parameter as? UIElementAccessingMock, self.textMarkerRangeMock)
            switch attribute {
            case "AXAttributedStringForTextMarkerRange":
                return UIElementAccessor("Plain text" as NSString)
            default: throw TestData.error
            }
        }
        // when
        await AssertThrowsError(try await extractor.selectedTextInfo())
        // then
        systemWideMock._subscriptGetAttribute.wasCalled(1)
        focusedElementMock._subscriptGetAttribute.wasCalled(1, withArguments: "AXSelectedTextMarkerRange")
        focusedElementMock._subscriptGetAttributeParameter.wasCalled(1)
        let argumentsHistory = focusedElementMock._subscriptGetAttributeParameter.argumentsHistory.map { $0.0 }
        XCTAssertEqual(argumentsHistory, ["AXAttributedStringForTextMarkerRange"])
    }
    
    /// Focused UI element exists; Selected text exists as attributed string; Selected text bounds doesn't exist.
    /// Should return selected text with no bounds.
    func testSelectedTextInfo_SelectedTextMarkerRange_NoBounds() async throws {
        // given
        systemWideMock._subscriptGetAttribute.returnValue = focusedElementMock
        focusedElementMock._subscriptGetAttribute.body = { attribute in
            switch attribute {
            case "AXSelectedTextMarkerRange": return self.textMarkerRangeMock
            default: throw TestData.error
            }
        }
        focusedElementMock._subscriptGetAttributeParameter.body = { args in
            let (attribute, parameter) = args
            XCTAssertIdentical(parameter as? UIElementAccessingMock, self.textMarkerRangeMock)
            switch attribute {
            case "AXAttributedStringForTextMarkerRange":
                return UIElementAccessor(NSAttributedString(string: "Selected Text"))
            default: throw TestData.error
            }
        }
        // when
        let result = try await extractor.selectedTextInfo()
        // then
        systemWideMock._subscriptGetAttribute.wasCalled(1)
        focusedElementMock._subscriptGetAttribute.wasCalled(1, withArguments: "AXSelectedTextMarkerRange")
        focusedElementMock._subscriptGetAttributeParameter.wasCalled(2)
        let argumentsHistory = focusedElementMock._subscriptGetAttributeParameter.argumentsHistory.map { $0.0 }
        XCTAssertEqual(argumentsHistory, ["AXAttributedStringForTextMarkerRange", "AXBoundsForTextMarkerRange"])
        XCTAssertEqual(result, SelectedTextInfo(text: "Selected Text", textFrame: nil))
    }
    
    /// Focused UI element exists; Selected text exists as attributed string; Selected text bounds exists but not as CGRect.
    /// Should return selected text with no bounds.
    func testSelectedTextInfo_SelectedTextMarkerRange_WrongBoundsType() async throws {
        // given
        systemWideMock._subscriptGetAttribute.returnValue = focusedElementMock
        focusedElementMock._subscriptGetAttribute.body = { attribute in
            switch attribute {
            case "AXSelectedTextMarkerRange": return self.textMarkerRangeMock
            default: throw TestData.error
            }
        }
        focusedElementMock._subscriptGetAttributeParameter.body = { args in
            let (attribute, parameter) = args
            XCTAssertIdentical(parameter as? UIElementAccessingMock, self.textMarkerRangeMock)
            switch attribute {
            case "AXAttributedStringForTextMarkerRange":
                return UIElementAccessor(NSAttributedString(string: "Selected Text"))
            case "AXBoundsForTextMarkerRange":
                return UIElementAccessor(NSNumber(value: 1))
            default: throw TestData.error
            }
        }
        // when
        let result = try await extractor.selectedTextInfo()
        // then
        systemWideMock._subscriptGetAttribute.wasCalled(1)
        focusedElementMock._subscriptGetAttribute.wasCalled(1, withArguments: "AXSelectedTextMarkerRange")
        focusedElementMock._subscriptGetAttributeParameter.wasCalled(2)
        let argumentsHistory = focusedElementMock._subscriptGetAttributeParameter.argumentsHistory.map { $0.0 }
        XCTAssertEqual(argumentsHistory, ["AXAttributedStringForTextMarkerRange", "AXBoundsForTextMarkerRange"])
        XCTAssertEqual(result, SelectedTextInfo(text: "Selected Text", textFrame: nil))
    }
    
    /// Focused UI element exists; Selected text range exists; Selected text exists as plain string; Selected text bounds exists.
    /// Should return selected text with bounds.
    func testSelectedTextInfo_SelectedTextRange() async throws {
        // given
        systemWideMock._subscriptGetAttribute.returnValue = focusedElementMock
        focusedElementMock._subscriptGetAttribute.body = { attribute in
            switch attribute {
            case kAXSelectedTextRangeAttribute: return self.textRangeMock
            case kAXSelectedTextAttribute: return UIElementAccessor("Plain Selected Text" as NSString)
            default: throw TestData.error
            }
        }
        focusedElementMock._subscriptGetAttributeParameter.body = { args in
            let (attribute, parameter) = args
            XCTAssertIdentical(parameter as? UIElementAccessingMock, self.textRangeMock)
            switch attribute {
            case kAXBoundsForRangeParameterizedAttribute:
                var bounds = TestData.textFrame
                return UIElementAccessor(AXValueCreate(.cgRect, &bounds)!)
            default: throw TestData.error
            }
        }
        // when
        let result = try await extractor.selectedTextInfo()
        // then
        systemWideMock._subscriptGetAttribute.wasCalled(1)
        focusedElementMock._subscriptGetAttribute.wasCalled(3, withArguments: ["AXSelectedTextMarkerRange", kAXSelectedTextRangeAttribute, kAXSelectedTextAttribute])
        focusedElementMock._subscriptGetAttributeParameter.wasCalled(1)
        XCTAssertEqual(result, SelectedTextInfo(text: "Plain Selected Text", textFrame: TestData.textFrame))
    }
    
    /// Focused UI element exists; Selected text range exists; Selected text doesn't exist.
    /// Should throw error.
    func testSelectedTextInfo_SelectedTextRange_NoSelectedText() async throws {
        // given
        systemWideMock._subscriptGetAttribute.returnValue = focusedElementMock
        focusedElementMock._subscriptGetAttribute.body = { attribute in
            switch attribute {
            case kAXSelectedTextRangeAttribute: return self.textRangeMock
            default: throw TestData.error
            }
        }
        // when
        await AssertThrowsError(try await extractor.selectedTextInfo())
        // then
        systemWideMock._subscriptGetAttribute.wasCalled(1)
        focusedElementMock._subscriptGetAttribute.wasCalled(3, withArguments: ["AXSelectedTextMarkerRange", kAXSelectedTextRangeAttribute, kAXSelectedTextAttribute])
        focusedElementMock._subscriptGetAttributeParameter.wasCalled(0)
    }
    
    /// Focused UI element exists; Selected text range exists; Selected text exists, but not as plain string.
    /// Should throw error
    func testSelectedTextInfo_SelectedTextRange_WrongSelectedTextType() async throws {
        // given
        systemWideMock._subscriptGetAttribute.returnValue = focusedElementMock
        focusedElementMock._subscriptGetAttribute.body = { attribute in
            switch attribute {
            case kAXSelectedTextRangeAttribute: return self.textRangeMock
            case kAXSelectedTextAttribute: return UIElementAccessor(NSNumber(value: 1))
            default: throw TestData.error
            }
        }
        // when
        await AssertThrowsError(try await extractor.selectedTextInfo())
        // then
        systemWideMock._subscriptGetAttribute.wasCalled(1)
        focusedElementMock._subscriptGetAttribute.wasCalled(3, withArguments: ["AXSelectedTextMarkerRange", kAXSelectedTextRangeAttribute, kAXSelectedTextAttribute])
        focusedElementMock._subscriptGetAttributeParameter.wasCalled(0)
    }
    
    /// Focused UI element exists; Selected text range exists; Selected text exists as plain string; Selected text bounds doesn't exist.
    /// Should return selected text with no bounds.
    func testSelectedTextInfo_SelectedTextRange_NoBounds() async throws {
        // given
        systemWideMock._subscriptGetAttribute.returnValue = focusedElementMock
        focusedElementMock._subscriptGetAttribute.body = { attribute in
            switch attribute {
            case kAXSelectedTextRangeAttribute: return self.textRangeMock
            case kAXSelectedTextAttribute: return UIElementAccessor("Plain Selected Text" as NSString)
            default: throw TestData.error
            }
        }
        focusedElementMock._subscriptGetAttributeParameter.body = { args in
            let (_, parameter) = args
            XCTAssertIdentical(parameter as? UIElementAccessingMock, self.textRangeMock)
            throw TestData.error
        }
        // when
        let result = try await extractor.selectedTextInfo()
        // then
        systemWideMock._subscriptGetAttribute.wasCalled(1)
        focusedElementMock._subscriptGetAttribute.wasCalled(3, withArguments: ["AXSelectedTextMarkerRange", kAXSelectedTextRangeAttribute, kAXSelectedTextAttribute])
        focusedElementMock._subscriptGetAttributeParameter.wasCalled(1)
        XCTAssertEqual(result, SelectedTextInfo(text: "Plain Selected Text", textFrame: nil))
    }
    
    /// Focused UI element exists; Selected text range exists; Selected text exists as plain string; Selected text bounds exists but not as CGRect.
    /// Should return selected text with no bounds.
    func testSelectedTextInfo_SelectedTextRange_WrongBoundsType() async throws {
        // given
        systemWideMock._subscriptGetAttribute.returnValue = focusedElementMock
        focusedElementMock._subscriptGetAttribute.body = { attribute in
            switch attribute {
            case kAXSelectedTextRangeAttribute: return self.textRangeMock
            case kAXSelectedTextAttribute: return UIElementAccessor("Plain Selected Text" as NSString)
            default: throw TestData.error
            }
        }
        focusedElementMock._subscriptGetAttributeParameter.body = { args in
            let (attribute, parameter) = args
            XCTAssertIdentical(parameter as? UIElementAccessingMock, self.textRangeMock)
            switch attribute {
            case kAXBoundsForRangeParameterizedAttribute: return UIElementAccessor(NSNumber(value: 1))
            default: throw TestData.error
            }
        }
        // when
        let result = try await extractor.selectedTextInfo()
        // then
        systemWideMock._subscriptGetAttribute.wasCalled(1)
        focusedElementMock._subscriptGetAttribute.wasCalled(3, withArguments: ["AXSelectedTextMarkerRange", kAXSelectedTextRangeAttribute, kAXSelectedTextAttribute])
        focusedElementMock._subscriptGetAttributeParameter.wasCalled(1)
        XCTAssertEqual(result, SelectedTextInfo(text: "Plain Selected Text", textFrame: nil))
    }
}

private enum TestData {
    static let error = TextError("TestData error")
    static let textFrame = CGRect(x: 20, y: 50, width: 30, height: 10)
}
