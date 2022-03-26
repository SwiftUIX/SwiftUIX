//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import Swift
import SwiftUI

class NSHostingStatusBarPopover<ID: Equatable, Content: View>: NSHostingPopover<Content> {
    var _statusBarBase = NSStatusBar()
    var _statusItemBase: NSStatusItem? {
        didSet {
            _statusItemBase?.button?.action = #selector(togglePopover(sender:))
            _statusItemBase?.button?.target = self
        }
    }
    
    var statusItem: StatusItem<ID, Content> {
        didSet {
            updateStatusBarItem(oldValue: oldValue)
        }
    }
    
    var isActive: Binding<Bool>? {
        didSet {
            if let isActive = isActive {
                if isActive.wrappedValue, !self.isShown {
                    present(nil)
                }
            }
        }
    }
    
    init(item: StatusItem<ID, Content>) {
        self.statusItem = item
        
        super.init(rootView: item.content)
        
        behavior = NSPopover.Behavior.transient
        
        updateStatusBarItem(oldValue: item)
        
        _ = Unmanaged.passUnretained(self).retain() // fixes a crash
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateStatusBarItem(oldValue: StatusItem<ID, Content>) {
        if let item = _statusItemBase {
            if oldValue.id != statusItem.id {
                _statusBarBase.removeStatusItem(item)
                _statusItemBase = nil
            }
            
            if oldValue.length != statusItem.length {
                _statusBarBase.removeStatusItem(item)
                _statusItemBase = nil
            }
        }
        
        rootView = statusItem.content
        
        if _statusItemBase == nil {
            _statusItemBase = _statusBarBase.statusItem(withLength: statusItem.length)
        }
        
        statusItem.update(_statusItemBase!)
        
        if let isActive = isActive, isActive.wrappedValue, !isShown {
            present(nil)
        }
    }
    
    func present(_ sender: AnyObject?) {
        guard let statusBarButton = _statusItemBase?.button else {
            return
        }
        
        show(
            relativeTo: statusBarButton.bounds,
            of: statusBarButton,
            preferredEdge: NSRectEdge.maxY
        )
        
        isActive?.wrappedValue = true
    }
    
    func hide(_ sender: AnyObject?) {
        performClose(sender)

        isActive?.wrappedValue = false
    }
    
    @objc func togglePopover(sender: AnyObject?) {
        if isShown {
            hide(sender)
        } else {
            present(sender)
        }
    }
    
    deinit {
        if let item = _statusItemBase {
            item.statusBar?.removeStatusItem(item)
        }
    }
}

#endif
