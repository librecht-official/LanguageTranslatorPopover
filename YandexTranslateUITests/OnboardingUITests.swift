//
//  Created by Vladislav Librecht on 17.11.2024
//

import XCTest

final class OnboardingUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["test"]
    }

    override func tearDownWithError() throws {
        app = nil
    }
    
    // This test can only be passed if app has no access to Accessibility on current testing machine.
    // Before running this test make sure to uncheck Accessibility Access for the app in System Settings.
    func testAccessibilityAccessCheckOptionPrompt() {
        app.launchArguments = []
        app.launch()
        
        let universalAccessAuthWarnApp = XCUIApplication(bundleIdentifier: "com.apple.accessibility.universalAccessAuthWarn")
        XCTAssertTrue(universalAccessAuthWarnApp.windows.count > 0, "Accessibility Access dialog doesn't exist")
    }

    func testWhenAXAccessIsNeverGranted() throws {
        app.launch()
        
        It_should_show_accessability_auth_warn_message()
        Context("Wait 5 seconds") {
            Thread.sleep(forTimeInterval: 5)
        }
        It_should_show_accessability_auth_warn_message()
    }
    
    func It_should_show_accessability_auth_warn_message() {
        let window = app.windows["onboarding"]
        let messageLabel = window.staticTexts["message_label"]
        Context("It should show accessability auth warn message") {
            XCTAssertTrue(messageLabel.exists, "message label doesn't exist")
            XCTAssertEqual(messageLabel.value as? String, universalAccessAuthWarnMessage, "wrong message")
        }
    }
    
    func testWhenAXAccessIsNotGrantedInitially_ThenGranted() throws {
        app.launchArguments.append("AXProcessTrusted")
        app.launch()
        
        let window = app.windows["onboarding"]
        
        It_should_show_accessability_auth_warn_message()
        
        Context("It should then change message to instruction how to use app") {
            let expectMessageToChange = expectation(for: NSPredicate(format: "value == %@", howToUseAppMessage), evaluatedWith: window.staticTexts["message_label"])
            wait(for: [expectMessageToChange], timeout: 5)
        }
    }
    
    func testWhenAXAccessIsGrantedInitially() throws {
        app.launchArguments.append(contentsOf: ["AXProcessTrustedWithOptions", "AXProcessTrusted"])
        app.launch()
        
        let window = app.windows["onboarding"]
        
        Context("It should show instruction how to use app") {
            XCTAssertTrue(window.staticTexts["message_label"].exists, "message label doesn't exist")
            XCTAssertEqual(window.staticTexts["message_label"].value as? String, howToUseAppMessage, "wrong message")
        }
        Context("It should not present translator view") {
            let translatorPanel = app.dialogs["translator_panel"]
            let popovers = translatorPanel.popovers
            XCTAssertFalse(translatorPanel.exists, "translator panel does exist")
            XCTAssertEqual(popovers.count, 0, "translator popover does exist")
            XCTAssertFalse(popovers.element.groups["translator_web_view"].exists, "translator web view does exist")
        }
    }

//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
    
    let universalAccessAuthWarnMessage = "Accessibility is not allowed for this app. To use this app go to\nSystem Preferences > Security & Privacy > Privacy tab > Accessibility.\nSelect checkbox for “Yandex Translate“."
    let howToUseAppMessage = "Select text in any application and press ⌃Z hotkey. You can close this window."
}

func Context<Result>(_ description: String, block: () throws -> Result) rethrows -> Result {
    try XCTContext.runActivity(named: description, block: { a in try block() })
}

//extension XCUIApplication.State: CustomStringConvertible {
//    public var description: String {
//        switch self {
//        case .notRunning: return "notRunning"
//        case .runningBackground: return "runningBackground"
//        case .runningForeground: return "runningForeground"
//        case .unknown: return "unknown"
//        @unknown default: return "?"
//        }
//    }
//}
