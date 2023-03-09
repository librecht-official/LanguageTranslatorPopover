//
//  Created by Vladislav Librecht on 09.03.2023
//

// sourcery: AutoMockable
protocol TaskProtocol {
    static func sleep(nanoseconds: UInt64) async throws
}

extension Task: TaskProtocol where Success == Never, Failure == Never {
}
