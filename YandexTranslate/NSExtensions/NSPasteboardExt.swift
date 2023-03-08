//
//  Created by Vladislav Librecht on 08.03.2023.
//

import Cocoa

protocol NSPasteboardProtocol {
    func data(forType dataType: NSPasteboard.PasteboardType) -> Data?
    
    func string(forType dataType: NSPasteboard.PasteboardType) -> String?
    
    @discardableResult
    func prepareForNewContents() -> Int
    
    @discardableResult
    func setData(_ data: Data?, forType dataType: NSPasteboard.PasteboardType) -> Bool
}

extension NSPasteboard: NSPasteboardProtocol {
    func prepareForNewContents() -> Int {
        prepareForNewContents(with: [])
    }
}
