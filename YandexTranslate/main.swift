//  Created by Vladislav Librecht on 06.03.2023.
//

import Cocoa

//let delegate: NSApplicationDelegate = ProcessInfo.processInfo.arguments.contains("test") ? TestAppDelegate() : AppDelegate()
let delegate = AppDelegate()
NSApplication.shared.delegate = delegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
