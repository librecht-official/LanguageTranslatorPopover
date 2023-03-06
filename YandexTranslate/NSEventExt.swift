//
//  NSEventExt.swift
//  YandexTranslate
//
//  Created by Vladislav Librecht on 06.03.2023.
//

import AppKit

protocol GlobalMonitoring {
    @discardableResult
    static func addGlobalMonitorForEvents(matching mask: NSEvent.EventTypeMask, handler block: @escaping (NSEvent) -> Void) -> Any?
}

extension NSEvent: GlobalMonitoring {}
