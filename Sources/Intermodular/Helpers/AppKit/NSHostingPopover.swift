//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import Swift
import SwiftUI

open class NSHostingPopover<Content: View>: NSPopover {
    private var presentationManager: PresentationManager!
    
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
        
        presentationManager = .init(self)
        
        let contentViewController = CocoaHostingController(mainView: ContentWrapper(content: rootView, owner: self))
        
        contentViewController.parentPopover = self
        
        self.animates = true
        self.contentViewController = contentViewController
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Auxiliary Implementation -

extension NSHostingPopover {
    private struct ContentWrapper: View {
        var content: Content
        
        weak var owner: NSHostingPopover?
        
        var body: some View {
            if let owner = owner {
                content
                    .environment(\.presentationManager, owner.presentationManager)
                    .onChangeOfFrame { _ in
                        owner._contentViewController.view.layout()
                    }
            }
        }
    }
    
    private class PresentationManager: SwiftUIX.PresentationManager {
        private unowned let popover: NSHostingPopover
        
        public var isPresented: Bool {
            popover.isShown
        }
        
        public init(_ popover: NSHostingPopover)  {
            self.popover = popover
        }
        
        public func dismiss() {
            popover.performClose(nil)
        }
    }
}

#endif
