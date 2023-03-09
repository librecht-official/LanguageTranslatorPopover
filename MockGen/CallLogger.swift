//
//  Created by Vladislav Librecht on 09.03.2023
//

public final class CallLogger {
    public private(set) var records: String = ""
    private var counter: Int = 0
    
    public init() {
    }
    
    public func log(function: CustomStringConvertible, _ input: Any?) {
        records.append("\(counter). \(function)\n")
        counter += 1
    }
}
