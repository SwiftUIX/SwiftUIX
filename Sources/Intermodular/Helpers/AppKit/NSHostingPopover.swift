//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import Swift
import SwiftUI

open class NSHostingPopover<Content: View>: NSPopover {
    var presentationManager: PresentationManager!
    
    var _contentViewController: NSHostingController<ContentWrapper> {
        contentViewController as! NSHostingController<ContentWrapper>
    }
    
    public var rootView: Content {
        get {
            _contentViewController.rootView.content
        } set {
            _contentViewController.rootView = .init(content: newValue, owner: self)
            
            contentSize = _contentViewController.sizeThatFits(in: Screen.main.bounds.size)
        }
    }
    
    public init(rootView: Content) {
        super.init()
        
        presentationManager = .init(self)

        contentViewController = NSHostingController(rootView: ContentWrapper(content: rootView, owner: self))
        contentSize = _contentViewController.sizeThatFits(in: Screen.main.bounds.size)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Auxiliary Implementation -

extension NSHostingPopover {
    struct ContentWrapper: View {
        let content: Content
        
        weak var owner: NSHostingPopover?
        
        var body: some View {
            owner.ifSome { owner in
                content
                    .environment(\.presentationManager, owner.presentationManager)
            }
        }
    }
    
    class PresentationManager: SwiftUIX.PresentationManager {
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
