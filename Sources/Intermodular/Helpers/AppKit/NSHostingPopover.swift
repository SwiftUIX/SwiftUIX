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
    
    override open func show(
        relativeTo positioningRect: NSRect,
        of positioningView: NSView,
        preferredEdge: NSRectEdge
    ) {
        _contentViewController.mainView.parentBox.wrappedValue = self
        
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
        
        super.show(
            relativeTo: positioningRect,
            of: positioningView,
            preferredEdge: preferredEdge
        )
    }
    
    // MARK: - NSPopoverDelegate -
    
    public func popoverDidClose(_ notification: Notification) {
        contentViewController = nil
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
