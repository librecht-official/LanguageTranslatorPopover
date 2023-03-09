//
//  Created by Vladislav Librecht on 09.03.2023
//

import XCTest
import Carbon
import SnapshotTesting
@testable import YandexTranslate

@MainActor
final class PasteboardBasedSelectedTextExtractorTests: XCTestCase {
    var extractor: _PasteboardBasedSelectedTextExtractor<SystemEventMock, TaskMock>!
    var pasteboardMock: NSPasteboardMock!
    var eventDispatcherMock: SystemEventDispatchingMock!
    var eventMocks: [SystemEventMock] = []
    var callLogger: CallLogger!
    
    override class func setUp() {
        SnapshotTesting.isRecording = false
    }
    
    override func setUpWithError() throws {
        pasteboardMock = NSPasteboardMock(self)
        eventDispatcherMock = SystemEventDispatchingMock(self)
        extractor = _PasteboardBasedSelectedTextExtractor(pasteboard: pasteboardMock, eventDispatcher: eventDispatcherMock)
        
        pasteboardMock._prepareForNewContents.returnValue = 0
        pasteboardMock._setDataForType.returnValue = true
        pasteboardMock._stringForType.returnValue = "Result"
        var counter = -1
        eventMocks = [SystemEventMock(self), SystemEventMock(self), SystemEventMock(self), SystemEventMock(self)]
        SystemEventMock._keyDown.body = { _ in
            counter += 1
            return self.eventMocks[counter]
        }
        
        callLogger = CallLogger()
    }
    
    override func tearDown() {
        SystemEventMock.resetState()
        TaskMock.resetState()
    }
    
    // MARK: - selectedTextInfo
    
    func testSelectedTextInfo_PasteboardIsEmpty() async throws {
        // given
        pasteboardMock._stringForType.returnValue = nil
        // then
        await AssertThrowsError(try await extractor.selectedTextInfo())
    }
    
    func testSelectedTextInfo() async throws {
        // given
        pasteboardMock._dataForType.addLogger(callLogger).returnValue = TestData.pasteboardData
        pasteboardMock._stringForType.addLogger(callLogger)
        pasteboardMock._prepareForNewContents.addLogger(callLogger)
        pasteboardMock._setDataForType.addLogger(callLogger)
        eventDispatcherMock._postEventTap.addLogger(callLogger)
        TaskMock._sleepNanoseconds.addLogger(callLogger)
        
        // when
        let info = try await extractor.selectedTextInfo()
        // then
        XCTAssertEqual(info, SelectedTextInfo(text: "Result", textFrame: nil))
        
        assertSnapshot(matching: callLogger.records, as: .description, named: "call_log")
        
        pasteboardMock._stringForType.wasCalled(1, withArguments: .string)
        pasteboardMock._dataForType.wasCalled(1, withArguments: .string)
        pasteboardMock._setDataForType.wasCalled(1) { data, dataType in
            XCTAssertEqual(data, TestData.pasteboardData)
            XCTAssertEqual(dataType, .string)
        }
        TaskMock._sleepNanoseconds.wasCalled(1, withArguments: 100_000_000)
        eventDispatcherMock._postEventTap.wasCalled(4)
        eventDispatcherMock._postEventTap.argumentsHistory.enumerated().forEach { i, args in
            let (event, location) = args
            XCTAssertIdentical(event as? SystemEventMock, eventMocks[i])
            XCTAssertEqual(location, .cghidEventTap)
        }
    }
}

private enum TestData {
    static let pasteboardData = Data("something".utf8)
}
