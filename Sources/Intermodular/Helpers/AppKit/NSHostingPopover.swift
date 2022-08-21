//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import Swift
import SwiftUI

open class NSHostingPopover<Content: View>: NSPopover {
    private var _contentViewController: CocoaHostingController<ContentWrapper> {
        contentViewController as! CocoaHostingController<ContentWrapper>
    }
    
    public var rootView: Content {
        get {
            _contentViewController.mainView.content
        } set {
            _contentViewController.mainView.content = newValue
            
            _contentViewController.view.layout()
        }
    }
    
    public init(rootView: Content) {
        super.init()
        
        let contentViewController = CocoaHostingController(
            mainView: ContentWrapper(
                content: rootView,
                parent: self
            )
        )
        
        contentViewController.parentPopover = self
        
        self.animates = true
        self.contentViewController = contentViewController
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func show(
        relativeTo positioningRect: NSRect,
        of positioningView: NSView,
        preferredEdge: NSRectEdge
    ) {
        if _areAnimationsDisabledGlobally {
            animates = false
        }
        
        defer {
            if _areAnimationsDisabledGlobally {
                animates = true 
            }
        }

        super.show(
            relativeTo: positioningRect,
            of: positioningView,
            preferredEdge: preferredEdge
        )
    }
}

// MARK: - Auxiliary Implementation -

extension NSHostingPopover {
    private struct ContentWrapper: View {
        var content: Content
        
        weak var parent: NSHostingPopover?
        
        var body: some View {
            if let parent = parent {
                content
                    .environment(\.presentationManager, PresentationManager(parent))
                    .onChangeOfFrame { _ in
                        parent._contentViewController.view.layout()
                    }
            }
        }
    }
    
    private struct PresentationManager: SwiftUIX.PresentationManager {
        weak var popover: NSHostingPopover?
        
        public var isPresented: Bool {
            popover?.isShown ?? false
        }
        
        public init(_ popover: NSHostingPopover?)  {
            self.popover = popover
        }
        
        public func dismiss() {
            guard let popover = popover else {
                return assertionFailure()
            }
            
            popover.performClose(nil)
        }
    }
}

#endif
