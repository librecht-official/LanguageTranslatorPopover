//
//  Created by Vladislav Librecht on 16.11.2024
//

import Foundation

enum Environment {
    static var isTest = false
}

// MARK: - DispatchSourceTimer

extension Environment {
    static var dsTimerMock: DispatchSourceTimer!
}

func DI(_ declared: DispatchSourceTimer) -> DispatchSourceTimer {
    Environment.isTest ? Environment.dsTimerMock : declared
}

// MARK: - NotificationCenter

extension Environment {
    static var notificationCenterMock: NotificationCenter!
}

func DI(_ declared: NotificationCenter) -> NotificationCenter {
    Environment.isTest ? Environment.notificationCenterMock : declared
}
