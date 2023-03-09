//  Created by Vladislav Librecht on 06.03.2023.
//

import AppKit

protocol GlobalMonitoring {
    @discardableResult
    static func addGlobalMonitorForEvents(matching mask: NSEvent.EventTypeMask, handler block: @escaping (NSEvent) -> Void) -> Any?
}

extension NSEvent: GlobalMonitoring {}

// sourcery: AutoMockable
protocol SystemEvent {
    static func key(_ keyCode: Int, down: Bool, _ flags: CGEventFlags) -> Self?
    
    func post(tap: CGEventTapLocation)
}

extension CGEvent: SystemEvent {
    static func key(_ keyCode: Int, down: Bool, _ flags: CGEventFlags) -> Self? {
        let event = Self(keyboardEventSource: nil, virtualKey: CGKeyCode(keyCode), keyDown: down)
        event?.flags = flags
        return event
    }
}

// sourcery: AutoMockable
protocol SystemEventDispatching {
    func post<Event: SystemEvent>(event: Event?, tap: CGEventTapLocation)
}

struct SystemEventDispatcher: SystemEventDispatching {
    func post<Event>(event: Event?, tap: CGEventTapLocation) where Event: SystemEvent {
        event?.post(tap: tap)
    }
}
