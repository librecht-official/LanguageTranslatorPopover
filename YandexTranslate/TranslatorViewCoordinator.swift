//
//  TranslatorViewCoordinator.swift
//  YandexTranslate
//
//  Created by Vladislav Librecht on 06.03.2023.
//

import Cocoa

protocol TranslatorViewCoordinating {
    func showPopover(text: String, textFrame: CGRect)
}

final class TranslatorViewCoordinator: NSObject, TranslatorViewCoordinating {
    let panel = NSPanel(contentRect: .zero, styleMask: .borderless, backing: .buffered, defer: true)// `defer: true` somehow (maybe in combination with other settings) allows to show window over apps in fullscreen mode
    let panelController: NSWindowController
    let popoverContent = TranslatorWebViewController()
    let popover = NSPopover()
    
    override init() {
        panel.backgroundColor = .clear
        panel.animationBehavior = .none
        panel.collectionBehavior = [.transient, .canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        panel.isFloatingPanel = true
        panel.styleMask = [.borderless, .utilityWindow, .nonactivatingPanel, .fullSizeContentView]
        
        panelController = NSWindowController(window: panel)
        
        super.init()
        
        popover.contentViewController = popoverContent
        popover.behavior = .transient
        popover.contentSize = popoverContent.contentSize
        popover.delegate = self
    }
    
    func showPopover(text: String, textFrame: CGRect) {
        guard let mainScreen = NSScreen.main else { return }
        var windowFrame = mainScreen.flipYAxis(of: textFrame)
        if windowFrame.width < 1 {
            windowFrame.size.width = 10
        }
        if windowFrame.height < 1 {
            windowFrame.size.height = 10
        }
        
        panel.setFrame(windowFrame, display: false)
        panelController.showWindow(nil)
        panel.makeKeyAndOrderFront(nil)
        panel.orderFrontRegardless()
        
        popoverContent.set(textToTranslate: text)
        let anchor = NSRect(origin: .zero, size: windowFrame.size)
        popover.show(relativeTo: anchor, of: panel.contentView!, preferredEdge: .minY)
    }
}

extension TranslatorViewCoordinator: NSPopoverDelegate {
    func popoverDidClose(_ notification: Notification) {
        panelController.close()
    }
}

extension NSScreen {
    func flipYAxis(of rect: CGRect) -> CGRect {
        CGRect(
            x: rect.origin.x,
            y: frame.height - rect.height - rect.origin.y,
            width: rect.width,
            height: rect.height
        )
    }
}
