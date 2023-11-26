//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import Swift
import SwiftUI

@_spi(Internal)
public class _AppKitMenuBarExtraPopover<ID: Equatable, Content: View>: NSHostingPopover<Content> {
    private lazy var menuBarExtraCoordinator = _CocoaMenuBarExtraCoordinator<ID, Content>(
        item: item,
        action: { [weak self] in
            self?.togglePopover(sender: nil)
        }
    )
    
    public var item: MenuBarItem<ID, Content> {
        didSet {
            menuBarExtraCoordinator.item = item
        }
    }
    
    var _isActiveBinding: Binding<Bool>? {
        didSet {
            if let _isActiveBinding = _isActiveBinding {
                if _isActiveBinding.wrappedValue, !self.isShown {
                    present(nil)
                }
            }
        }
    }
    
    public init(item: MenuBarItem<ID, Content>) {
        self.item = item
        
        super.init(rootView: item.content)
        
        menuBarExtraCoordinator.item = item
        
        behavior = NSPopover.Behavior.transient
        
        _ = Unmanaged.passUnretained(self).retain() // fixes a crash
        
        if let _isActiveBinding, _isActiveBinding.wrappedValue, !isShown {
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
        guard let statusBarButton = menuBarExtraCoordinator.cocoaStatusItem.button else {
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
        
        _isActiveBinding?.wrappedValue = true
    }
    
    private func hide(_ sender: AnyObject?) {
        performClose(nil)
        
        _isActiveBinding?.wrappedValue = false
    }
}

#endif
