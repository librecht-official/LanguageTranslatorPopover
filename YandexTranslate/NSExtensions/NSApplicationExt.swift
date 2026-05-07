//
//  Created by Vladislav Librecht on 26.11.2024
//

import Cocoa

// sourcery: AutoMockable
protocol TerminatesApp {
    func terminate(_ sender: Any?)
}

extension NSApplication: TerminatesApp {}
