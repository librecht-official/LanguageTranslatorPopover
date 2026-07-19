//  Created by Vladislav Librecht on 05.03.2023.
//

import Cocoa
import OSLog

class AppDelegate: NSObject, NSApplicationDelegate {
    let notificationCenter = NotificationCenter.default
    var onboardingWindowController: NSWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Log.app.debug("-> applicationDidFinishLaunching")
        
        var topLevelObjects: NSArray?
        Bundle.main.loadNibNamed("MainMenu", owner: self, topLevelObjects: &topLevelObjects)
        NSApplication.shared.mainMenu = topLevelObjects?.filter { $0 is NSMenu }.first as? NSMenu
        
        onboardingWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateInitialController() as? NSWindowController
        onboardingWindowController?.window?.setContentSize(NSSize(width: 480, height: 270))
        onboardingWindowController?.showWindow(nil)
        
        Log.app.debug("applicationDidFinishLaunching ->")
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        Log.app.debug("-> applicationShouldHandleReopen")
        notificationCenter.post(name: .YTShowTranslatorPopover, object: nil)
        return true
    }
}
