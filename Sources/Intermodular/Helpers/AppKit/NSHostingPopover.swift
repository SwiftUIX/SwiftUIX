//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import Swift
import SwiftUI

/// An AppKit popover that hosts SwiftUI view hierarchy.
open class NSHostingPopover<Content: View>: NSPopover, NSPopoverDelegate {
    private var _contentViewController: CocoaHostingController<ContentWrapper> {
        if let contentViewController = contentViewController {
            return contentViewController as! CocoaHostingController<ContentWrapper>
        } else {
            let contentViewController = CocoaHostingController<ContentWrapper>(mainView: .init(parentBox: .init(nil), content: rootView))
            
            self.contentViewController = contentViewController
            
            return contentViewController
        }
    }
    
    public var rootView: Content {
        didSet {
            _contentViewController.mainView.content = rootView
            _contentViewController.view.layout()
        }
    }
    
    public init(rootView: Content) {
        self.rootView = rootView
        
        super.init()
        
        _contentViewController.parentPopover = self
        
        self.animates = true
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func _setShouldHideAnchor(_ hide: Bool) {
        setValue(hide, forKeyPath: "shouldHideAnchor")
    }
    
    override open func show(
        relativeTo positioningRect: NSRect,
        of positioningView: NSView,
        preferredEdge: NSRectEdge
    ) {
        _contentViewController.mainView.parentBox.wrappedValue = self
        
        if _contentViewController.preferredContentSize.isAreaZero {
            _contentViewController.preferredContentSize = _contentViewController.sizeThatFits(.init(fixedSize: (true, true)))
        }
        
        let _animates = self.animates
        
        if _areAnimationsDisabledGlobally {
            animates = false
        }
        
        defer {
            if _areAnimationsDisabledGlobally {
                DispatchQueue.main.async {
                    self.animates = _animates
                }
            }
        }
                
        func _show() {
            assert(!positioningView.frame.size.isAreaZero)
            
            let currentFirstResponder = NSWindow._firstKeyInstance?.firstResponder
            let currentKeyWindow = NSWindow._firstKeyInstance

            if self.behavior == .transient {
                self.behavior = .applicationDefined
                self.behavior = .transient
            }
            
            super.show(
                relativeTo: positioningRect,
                of: positioningView,
                preferredEdge: preferredEdge
            )
                        
            assert(isShown)
                        
            DispatchQueue.main.async {
                if self.behavior == .transient {
                    self.contentViewController?.view.window?.resignKey()
                    
                    assert((self.contentViewController?.view.window?.isKeyWindow ?? false) == false)
                    
                    currentKeyWindow?.makeKeyAndOrderFront(nil)
                    currentKeyWindow?.makeFirstResponder(currentFirstResponder)
                }
            }
        }
        
        if positioningView.frame.size.isAreaZero && (positioningView.window?.frame.size ?? .zero).isAreaZero {
            let windowIsPresented = positioningView.window != nil
            
            DispatchQueue.main.async {
                guard positioningView.window != nil else {
                    assert(windowIsPresented)
                    
                    return
                }
                
                _show()
            }
        } else {
            _show()
        }
    }
    
    override open func close() {
        super.close()
    }
    
    override open func performClose(_ sender: Any?) {
        super.performClose(sender)
    }
    
    // MARK: - NSPopoverDelegate -
    
    public func popoverDidClose(_ notification: Notification) {
        contentViewController = nil
    }
}

private var _NSHostingPopover_transientPopoverWindowClass: AnyClass? = nil

extension NSHostingPopover {
    private func swizzleWindowIfNeeded() {
        guard let window = contentViewController?.view.window else {
            return
        }
        
        guard type(of: window) != _NSHostingPopover_transientPopoverWindowClass else {
            return
        }

        let _NSPopoverWindowClass = type(of: window)
        
        if _NSHostingPopover_transientPopoverWindowClass == nil {
            _NSHostingPopover_transientPopoverWindowClass = objc_allocateClassPair(_NSPopoverWindowClass, "CustomWindow", 0)
        
            objc_registerClassPair(_NSHostingPopover_transientPopoverWindowClass!)

            let originalMethod = class_getInstanceMethod(NSWindow.self, #selector(NSWindow.makeKey))
            let swizzledMethod = class_getInstanceMethod(NSWindow.self, #selector(NSWindow.swizzled_transientPopoverWindowMakeKey))
            
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
        
        object_setClass(window, _NSHostingPopover_transientPopoverWindowClass!)
    }
}

extension NSWindow {
    @objc func swizzled_transientPopoverWindowMakeKey() {
        self.swizzled_transientPopoverWindowMakeKey()
    }
}

// MARK: - Auxiliary

extension NSHostingPopover {
    private struct ContentWrapper: View {
        var parentBox: ObservableWeakReferenceBox<NSHostingPopover>
        
        var content: Content
        
        var body: some View {
            if parentBox.wrappedValue != nil {
                content
                    .environment(\.presentationManager, PresentationManager(parentBox))
                    .onChangeOfFrame { _ in
                        parentBox.wrappedValue?._contentViewController.view.layout()
                    }
            }
        }
    }
    
    private struct PresentationManager: SwiftUIX.PresentationManager {
        public let popoverBox: ObservableWeakReferenceBox<NSHostingPopover>
        
        public var isPresented: Bool {
            popoverBox.wrappedValue?.isShown ?? false
        }
        
        public init(_ popoverBox: ObservableWeakReferenceBox<NSHostingPopover>)  {
            self.popoverBox = popoverBox
        }
        
        public func dismiss() {
            guard let popover = popoverBox.wrappedValue else {
                return assertionFailure()
            }
            
            popover.performClose(nil)
        }
    }
}

#endif
