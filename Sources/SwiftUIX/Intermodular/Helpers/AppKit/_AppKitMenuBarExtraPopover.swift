//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import Swift
import SwiftUI

@_spi(Internal)
@_documentation(visibility: internal)
public class _AppKitMenuBarExtraPopover<ID: Hashable, Label: View, Content: View>: NSHostingPopover<Content> {
    private var eventMonitor: Any?
    
    private lazy var menuBarExtraCoordinator = _CocoaMenuBarExtraCoordinator<ID, Label, Content>(
        item: item,
        action: { [weak self] in
            self?.togglePopover(sender: nil)
        }
    )
    
    public var item: MenuBarItem<ID, Label, Content> {
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
    
    override public var _SwiftUIX_wantsFixForTransientNSPopover: Bool {
        false
    }
    
    public init(item: MenuBarItem<ID, Label, Content>) {
        self.item = item
        
        super.init(rootView: item.content)
                        
        _ = Unmanaged.passUnretained(self).retain() // fixes a crash
                
        _setUpMenuBarExtraPopover()
        
        if let _isActiveBinding, _isActiveBinding.wrappedValue, !isShown {
            present(nil)
        }
    }
    
    public init(coordinator: _CocoaMenuBarExtraCoordinator<ID, Label, Content>) {
        self.item = coordinator.item
        
        super.init(rootView: item.content)

        self.menuBarExtraCoordinator = coordinator
        
        _ = Unmanaged.passUnretained(self).retain() // fixes a crash
                    
        _setUpMenuBarExtraPopover()
        
        if let _isActiveBinding, _isActiveBinding.wrappedValue, !isShown {
            present(nil)
        }
    }
    
    private func _setUpMenuBarExtraPopover() {
        behavior = NSPopover.Behavior.semitransient
        animates = false
        
        _setShouldHideAnchor(true)

        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let `self` = self, let button = self.menuBarExtraCoordinator.cocoaStatusItem?.button else {
                return
            }
            
            if self.isShown {
                let location = button.convert(event.locationInWindow, from: nil)
                
                if !button.bounds.contains(location) {
                    self.close()
                }
            }
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
    
    public func toggle() {
        togglePopover(sender: nil)
    }
    
    private func present(_ sender: AnyObject?) {
        guard let statusBarButton = menuBarExtraCoordinator.cocoaStatusItem?.button else {
            return
        }
                
        var relativeFrame = statusBarButton.bounds
        
        relativeFrame.origin.y = -5
        
        self.animates = false
        
        assert(delegate != nil)
        
        show(
            relativeTo: relativeFrame,
            of: statusBarButton,
            preferredEdge: NSRectEdge.maxY
        )
                
        _isActiveBinding?.wrappedValue = true
    }
    
    private func activateApplication() {
        if NSApplication.shared.activationPolicy() != .accessory {
            if #available(macOS 14.0, *) {
                NSApp.activate()
            } else {
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
    
    private func hide(_ sender: AnyObject?) {
        performClose(nil)
        
        _isActiveBinding?.wrappedValue = false
    }
}

#endif
