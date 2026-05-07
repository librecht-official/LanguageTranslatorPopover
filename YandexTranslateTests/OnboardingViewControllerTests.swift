//
//  Created by Vladislav Librecht on 17.11.2024
//

import XCTest
@testable import YandexTranslate

@MainActor
final class OnboardingViewControllerTests: XCTestCase {
    var sut: OnboardingViewController!
    var translationActivator: TranslationActivatingMock!
    var ax: AccessibilityAPIMock!
//    var sl: MockingServiceLocator!
    var processMock: ProcessMock!
//    var newProcessStub: MethodStub<Void, Process>!
    var terminatesAppMock: TerminatesAppMock!
    var callLogger: CallLogger!
    
    override func setUpWithError() throws {
        let callLogger = CallLogger(); self.callLogger = callLogger
        let processMock = ProcessMock(id: "1337"); self.processMock = processMock
        terminatesAppMock = TerminatesAppMock(self)
        processMock.callLogger = callLogger
//        processMock._executableURL.addLogger(callLogger)
//        processMock._run.addLogger(callLogger)
        
//        sl = MockingServiceLocator()
//        sl.register(processMock as Process)
//        sl.register(terminatesAppMock as TerminatesApp)
        
        translationActivator = TranslationActivatingMock(self)
        ax = AccessibilityAPIMock(self)
        sut = NSStoryboard(name: "Main", bundle: nil).instantiateController(identifier: "Onboarding") as OnboardingViewController
        sut.translationActivator = translationActivator
        sut.ax = ax
//        sut.intervalOfAXTrustCheck = 0.1
//        sut.newProcess = { callLogger.log("create new process"); return processMock }
        sut.app = terminatesAppMock
//        sut.sl = sl
    }
    
    override func tearDown() {
//        Environment.mocks.removeAll()
    }
    
    // MARK: viewDidLoad
    
    func testViewDidLoad_ProcessIsTrusted() {
        // given
        ax._isProcessTrustedWithOptions.returnValue = true
        // when
        sut.loadView()
        // then
        let expectedOptions = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as CFString: true] as CFDictionary
        ax._isProcessTrustedWithOptions.wasCalled(1, withArguments: expectedOptions)
        
        XCTAssertEqual(sut.messageLabel.stringValue, "Select text in any application and press ⌃Z hotkey. You can close this window.")
        
        translationActivator._start.wasCalled(1)
        
        XCTAssertNil(sut.timer)
    }
    
    func testViewDidLoad_ProcessIsNeverTrusted() {
        // given
        ax._isProcessTrustedWithOptions.returnValue = false
        ax._isProcessTrusted.returnValue = false
        
        // when
        sut.loadView()
        sut.timer?.fire()
        
        // then
        It_should_say_that_app_is_not_trusted_accessibility_client()
        It_should_not_start_translation_activator()
        It_should_setup_timer()
        It_should_not_terminate_app()
    }
    
    func testViewDidLoad_ProcessIsNotTrustedFirst_ThenTrusted() {
        // given
        ax._isProcessTrustedWithOptions.returnValue = false
        ax._isProcessTrusted.returnValue = true
        
        // when
        sut.loadView()
        sut.timer?.fire()
        
        // then
//        It_should_say_that_app_is_not_trusted_accessibility_client()
//        It_should_not_start_translation_activator()
//        It_should_setup_timer()
//        It_should_create_new_process()
//        It_should_set_exec_URL_to(Bundle.main.executablePath!)
//        It_should_run_process()
//        It_should_terminate_app()
        
        verify([
            "create new process",
            "[ProcessMock(1337)] set executableURL to \(URL(fileURLWithPath: Bundle.main.executablePath!))",
            "[ProcessMock(1337)] call run()",
        ])
        
//        It should create new process
//        With process: It should set exec URL to Bundle.main.executablePath!
//        With process: It should call run
        
    }
    
    func verify(_ expectedLogs: [String]) {
        AssertEqual(callLogger.records, expectedLogs)
    }
    
    func It_should_say_that_app_is_not_trusted_accessibility_client() {
        AssertEqual(sut.messageLabel.stringValue, "Accessibility is not allowed for this app. To use this app go to\nSystem Preferences > Security & Privacy > Privacy tab > Accessibility.\nSelect checkbox for “Yandex Translate“.", "wrong message is set")
    }
    
    func It_should_not_start_translation_activator() {
        translationActivator._start.wasCalled(0)
    }
    
    func It_should_setup_timer() {
        XCTAssertNotNil(sut.timer)
//        AssertEqual(sut.timer?.timeInterval, sut.intervalOfAXTrustCheck, "wrong time interval is set")
    }
    
    func It_should_create_new_process() {
        AssertEqual(callLogger.records[0], "create new process", #function)
    }
    
    func It_should_set_exec_URL_to(_ path: String) {
        AssertEqual(processMock._executableURL.wasSet(1).stubValue, URL(fileURLWithPath: path), #function)
    }
    
    func It_should_run_process() {
        processMock._run.wasCalled(1)
    }
    
    func It_should_terminate_app() {
        terminatesAppMock._terminate.wasCalled(1)
    }
    
    func It_should_not_terminate_app() {
        terminatesAppMock._terminate.wasCalled(0)
    }
}

func AssertEqual<T>(
    _ expression1: @autoclosure () throws -> T,
    _ expression2: @autoclosure () throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) where T : Equatable {
    do {
        let lhs = try expression1(); let rhs = try expression2()
        if lhs != rhs {
            XCTFail("\(message()) - `\(lhs)` ≠ `\(rhs)`", file: file, line: line)
        }
    } catch {
        XCTFail("Thrown error: \(error)", file: file, line: line)
    }
}

//func It_should(
//    _ expression: @autoclosure () throws -> Bool,
//    file: StaticString = #filePath,
//    line: UInt = #line
//) {
//    XCTAssert(try expression(), "It should", file: file, line: line)
//}

//func create_new<T>(_ objectOfType: T.Type) -> Bool {
//    false
//}

//final class MockingServiceLocator: ServiceLocatorProtocol {
//    var mocks: [String: Any] = [:]
//    
//    func register<T>(_ object: T) {
//        let key = typeName(T.self)
//        mocks[key] = object
//    }
//    
//    var _managed = MethodStub<String, Void>(name: "managed", nil)
//    
//    func managed<T>(_ object: T) -> T {
//        let key = typeName(T.self)
//        _managed.callWith(arguments: key)
//        return mocks[key]! as! T
//    }
//    
//    private func typeName(_ some: Any) -> String {
//        (some is Any.Type) ? "\(some)" : "\(type(of: some))"
//    }
//}

class ProcessMock: Process {
    let id: String
    
    init(id: String) {
        self.id = id
    }
    
    weak var callLogger: CallLogger?
    
    var _executableURL = PropertyStub<URL>(name: "executableURL", nil)
    
    override var executableURL: URL? {
        get {
            callLogger?.log("[\(self)] get executableURL")
            return _executableURL._optionalValue
        }
        set {
            callLogger?.log("[\(self)] set executableURL to \(newValue.asString)")
            _executableURL._optionalValue = newValue
        }
    }
    
    var _run = MethodStub<Void, Void>(name: "run", nil)
    
    override func run() throws {
        callLogger?.log("[\(self)] call run()")
        _run.callWith(arguments: ())
    }
    
    override var description: String {
        "ProcessMock(\(id))"
    }
}
