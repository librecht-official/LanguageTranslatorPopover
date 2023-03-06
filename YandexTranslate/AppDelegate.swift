//
//  AppDelegate.swift
//  YandexTranslate
//
//  Created by Vladislav Librecht on 05.03.2023.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var onboardingWindowController: NSWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        onboardingWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateInitialController() as? NSWindowController
//        onboardingWindowController?.window?.setContentSize(NSSize(width: 480, height: 270))
//        onboardingWindowController?.showWindow(nil)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        onboardingWindowController?.showWindow(sender)
        return true
    }
}
