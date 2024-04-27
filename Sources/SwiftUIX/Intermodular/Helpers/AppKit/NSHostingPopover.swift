//
// Copyright (c) Vatsal Manot
//

#if os(macOS)
import AppKit
#endif
import Swift
import SwiftUI

#if os(iOS) || os(tvOS)
public protocol AppKitOrUIKitHostingPopoverProtocol {
    func enforceTransientBehavior()
}
#elseif os(macOS)
public protocol AppKitOrUIKitHostingPopoverProtocol: NSPopover {
    func enforceTransientBehavior()
}
#endif

#if os(macOS)
/// An AppKit popover that hosts SwiftUI view hierarchy.
open class NSHostingPopover<Content: View>: NSPopover, NSPopoverDelegate, AppKitOrUIKitHostingPopoverProtocol {
    private var _contentViewController: CocoaHostingController<ContentWrapper> {
        if let contentViewController = contentViewController {
            return contentViewController as! CocoaHostingController<ContentWrapper>
        } else {
            let result = CocoaHostingController<ContentWrapper>(
                mainView: .init(
                    parentBox: .init(nil),
                    content: rootView
                )
            )
            
            result.parentPopover = self
            result.mainView.parentBox.wrappedValue = self
            
            self.contentViewController = result

            if #available(macOS 13.0, *) {
                result.sizingOptions = [.preferredContentSize]
            }
                        
            return result
        }
    }
    
    public var rootView: Content {
        didSet {
            _contentViewController.mainView.content = rootView
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
    
    private weak var _rightfulKeyWindow: NSWindow?
    private weak var _rightfulFirstResponder: AppKitOrUIKitResponder?
    
    override open func show(
        relativeTo positioningRect: NSRect,
        of positioningView: NSView,
        preferredEdge: NSRectEdge
    ) {
        if _sizeContentToFit() {
            _showWellSized(
                relativeTo: positioningRect,
                of: positioningView,
                preferredEdge: preferredEdge
            )
        } else {
            DispatchQueue.main.async {
                assert(self._sizeContentToFit())
                
                self._showWellSized(
                    relativeTo: positioningRect,
                    of: positioningView,
                    preferredEdge: preferredEdge
                )
            }
        }
    }
    
    private func _showWellSized(
        relativeTo positioningRect: NSRect,
        of positioningView: NSView,
        preferredEdge: NSRectEdge
    ) {
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
        
        let deferShow = positioningView.frame.size.isAreaZero && (positioningView.window?.frame.size ?? .zero).isAreaZero
        
        if deferShow {
            let windowWasPresent = positioningView.window != nil
            
            DispatchQueue.main.async {
                guard positioningView.window != nil else {
                    assert(windowWasPresent)
                    
                    return
                }
                
                self._showUnconditionally(
                    relativeTo: positioningRect,
                    of: positioningView,
                    preferredEdge: preferredEdge
                )
            }
        } else {
            _showUnconditionally(
                relativeTo: positioningRect,
                of: positioningView,
                preferredEdge: preferredEdge
            )
        }
    }
    
    private func _showUnconditionally(
        relativeTo positioningRect: NSRect,
        of positioningView: NSView,
        preferredEdge: NSRectEdge
    ) {
        _rightfulKeyWindow = NSWindow._firstKeyInstance
        _rightfulFirstResponder = NSWindow._firstKeyInstance?.firstResponder
        
        if self.behavior == .transient {
            self.behavior = .applicationDefined
            self.behavior = .transient
        }
        
        super.show(
            relativeTo: positioningRect,
            of: positioningView,
            preferredEdge: preferredEdge
        )
                
        if self.behavior == .transient {
            DispatchQueue.main.async {
                self.enforceTransientBehavior()
            }
        }
    }
    
    override open func close() {
        _cleanUpPostShow()
        
        super.close()
    }
    
    override open func performClose(_ sender: Any?) {
        _cleanUpPostShow()
        
        super.performClose(sender)
    }
    
    // MARK: - NSPopoverDelegate -
    
    public func popoverDidShow(_ notification: Notification) {
        enforceTransientBehavior()
    }
    
    public func popoverDidClose(_ notification: Notification) {
        _cleanUpPostShow()
        
        contentViewController = nil
    }
    
    // MARK: - Internal
    
    private func _cleanUpPostShow() {
        _rightfulKeyWindow = nil
        _rightfulFirstResponder = nil
    }
    
    @discardableResult
    public func _sizeContentToFit() -> Bool {
        if _contentViewController.preferredContentSize.isAreaZero {
            _contentViewController._canBecomeFirstResponder = false
            
            _contentViewController._SwiftUIX_setNeedsLayout()
            _contentViewController._SwiftUIX_layoutIfNeeded()
            
            var size = _contentViewController.sizeThatFits(
                AppKitOrUIKitLayoutSizeProposal(fixedSize: (true, true)),
                layoutImmediately: true
            )
            
            if size.isAreaZero, !_contentViewController.view.fittingSize.isAreaZero {
                size = _contentViewController.view.fittingSize
            }
            
            _contentViewController.preferredContentSize = size
            
            assert(!size.isAreaZero)
            
            _contentViewController._canBecomeFirstResponder = nil
        }
        
        let hasFittingSize = !_contentViewController.preferredContentSize.isAreaZero
        
        if hasFittingSize, _contentViewController.view.frame.size.isAreaZero {
            _contentViewController.view.frame.size = _contentViewController.preferredContentSize
            
            _contentViewController.view._SwiftUIX_layoutIfNeeded()
        }
        
        return hasFittingSize
    }
    
    public var wantsTransientBehaviorEnforcement: Bool {
        guard isShown, contentViewController?.view.window != nil else {
            return false
        }
        
        return self.behavior == .transient
    }
    
    public func enforceTransientBehavior() {
        guard wantsTransientBehaviorEnforcement, let popoverWindow = self.contentViewController?.view.window else {
            return
        }
        
        popoverWindow.collectionBehavior = .transient
        
        let popoverWindowWasKey = popoverWindow.isKeyWindow
        
        if popoverWindow.isKeyWindow {
            popoverWindow.resignKey()
        }
        
        assert(popoverWindow.isKeyWindow == false)
        
        guard popoverWindowWasKey else {
            _cleanUpPostShow()
            
            return
        }
        
        if let previousKeyWindow = _rightfulKeyWindow {
            previousKeyWindow.makeKeyAndOrderFront(nil)
            
            if let responder = _rightfulFirstResponder, previousKeyWindow.firstResponder != responder {
                previousKeyWindow.makeFirstResponder(responder)
            }
        }
    }
}

// MARK: - Auxiliary

extension NSHostingPopover {
    private struct ContentWrapper: View {
        var parentBox: _SwiftUIX_ObservableWeakReferenceBox<NSHostingPopover>
        
        var content: Content
        
        @State private var didAppear: Bool = false
        
        var body: some View {
            ZStack {
                if parentBox.wrappedValue != nil {
                    content
                        .environment(\.presentationManager, PresentationManager(parentBox))
                        .onChangeOfFrame { _ in
                            guard !didAppear else {
                                return
                            }
                            
                            parentBox.wrappedValue?._contentViewController.view.layout()
                        }
                        .onAppear {
                            didAppear = true
                        }
                } else {
                    PerformAction {
                        print("Invalid hosting popover.")
                    }
                }
            }
        }
    }
    
    private struct PresentationManager: SwiftUIX.PresentationManager {
        public let popoverBox: _SwiftUIX_ObservableWeakReferenceBox<NSHostingPopover>
        
        public var isPresented: Bool {
            popoverBox.wrappedValue?.isShown ?? false
        }
        
        public init(_ popoverBox: _SwiftUIX_ObservableWeakReferenceBox<NSHostingPopover>)  {
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
