//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import Swift
import SwiftUI

public class NSHostingStatusBarPopover<ID: Equatable, Content: View>: NSHostingPopover<Content> {
    var item: MenuBarItem<ID, Content> {
        didSet {
            menuBarItemManager.item = item
        }
    }

    private lazy var menuBarItemManager: MenuBarItemCoordinator<ID, Content> = .init(item: item, action: { [weak self] in
        self?.togglePopover(sender: nil)
    })

    var isActive: Binding<Bool>? {
        didSet {
            if let isActive = isActive {
                if isActive.wrappedValue, !self.isShown {
                    present(nil)
                }
            }
        }
    }
    
    public init(item: MenuBarItem<ID, Content>) {
        self.item = item
        
        super.init(rootView: item.content)
        
        menuBarItemManager.item = item
        
        behavior = NSPopover.Behavior.transient
                        
        _ = Unmanaged.passUnretained(self).retain() // fixes a crash
        
        if let isActive = isActive, isActive.wrappedValue, !isShown {
            present(nil)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    @objc func togglePopover(sender: AnyObject?) {
        if isShown {
            hide(sender)
        } else {
            present(sender)
        }
    }

    private func present(_ sender: AnyObject?) {
        guard let statusBarButton = menuBarItemManager.cocoaStatusItem.button else {
            return
        }
        
        NSApp.activate(ignoringOtherApps: true)

        animates = false
        
        show(
            relativeTo: statusBarButton.bounds,
            of: statusBarButton,
            preferredEdge: NSRectEdge.maxY
        )
        
        animates = true
        
        isActive?.wrappedValue = true
    }
    
    private func hide(_ sender: AnyObject?) {
        performClose(nil)

        isActive?.wrappedValue = false
    }
}

#endif
