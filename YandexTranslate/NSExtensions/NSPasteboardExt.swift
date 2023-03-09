//
//  Created by Vladislav Librecht on 08.03.2023.
//

import Cocoa

// sourcery: AutoMockable
protocol NSPasteboardProtocol {
    // sourcery: stubName = "dataForType"
    func data(forType dataType: NSPasteboard.PasteboardType) -> Data?
    
    // sourcery: stubName = "stringForType"
    func string(forType dataType: NSPasteboard.PasteboardType) -> String?
    
    @discardableResult
    func prepareForNewContents() -> Int
    
    @discardableResult
    // sourcery: stubName = "setDataForType"
    func setData(_ data: Data?, forType dataType: NSPasteboard.PasteboardType) -> Bool
}

extension NSPasteboard: NSPasteboardProtocol {
    func prepareForNewContents() -> Int {
        prepareForNewContents(with: [])
    }
}
