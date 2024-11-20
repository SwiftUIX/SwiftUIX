//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS)

@_spi(Internal) import _SwiftUIX
#if os(macOS)
import AppKit
#endif
import Combine
import Swift
import SwiftUI

public protocol _AppKitOrUIKitHostingPopoverType: _AnyAppKitOrUIKitHostingPopover {
    @_spi(Internal)
    var _SwiftUIX_hostingPopoverPreferences: _AppKitOrUIKitHostingPopoverPreferences { get set }
    
    var isDetached: Bool { get }
    var isShown: Bool { get}
    
    func _SwiftUIX_layoutImmediately()
    func _SwiftUIX_dismiss()
    func _SwiftUIX_detachedWindowDidClose()

    func _SwiftUIX_applyFixForTransientNSPopover()
}

#if os(iOS) || os(tvOS) || os(visionOS)
@_documentation(visibility: internal)
open class _AnyAppKitOrUIKitHostingPopover: NSObject, _AppKitOrUIKitHostingPopoverType {
    public var _SwiftUIX_hostingPopoverPreferences: _AppKitOrUIKitHostingPopoverPreferences = nil
    
    public var isDetached: Bool {
        fatalError()
    }
    
    public var isShown: Bool {
        fatalError()
    }
    
    open func _SwiftUIX_layoutImmediately() {
        fatalError()
    }
    
    open func _SwiftUIX_dismiss() {
        fatalError()
    }
    
    public func _SwiftUIX_detachedWindowDidClose() {
        fatalError()
    }

    open func _SwiftUIX_applyFixForTransientNSPopover() {
        fatalError()
    }
}
#elseif os(macOS)
@_documentation(visibility: internal)
open class _AnyAppKitOrUIKitHostingPopover: NSPopover, _AppKitOrUIKitHostingPopoverType {
    public var _SwiftUIX_hostingPopoverPreferences: _AppKitOrUIKitHostingPopoverPreferences = nil

    open func _SwiftUIX_layoutImmediately() {
        fatalError()
    }
    
    open func _SwiftUIX_dismiss() {
        fatalError()
    }
    
    open func _SwiftUIX_detachedWindowDidClose() {
        fatalError()
    }
    
    open func _SwiftUIX_applyFixForTransientNSPopover() {
        fatalError()
    }
}
#endif

@_documentation(visibility: internal)
public struct _AppKitOrUIKitHostingPopoverConfiguration: ExpressibleByNilLiteral {
    fileprivate let _onClose: (() -> Void)?
    
    public init(
        onClose: (() -> Void)? = nil
    ) {
        self._onClose = onClose
    }
    
    public init(nilLiteral: ()) {
        self.init()
    }
}

#if os(macOS)
/// An AppKit popover that hosts SwiftUI view hierarchy.
@_documentation(visibility: internal)
open class NSHostingPopover<Content: View>: _AnyAppKitOrUIKitHostingPopover, NSPopoverDelegate, ObservableObject {
    typealias _ContentWrappingView = _AppKitOrUIKitHostingWindowContent<Content>
    typealias _ContentViewControllerType = CocoaHostingController<_ContentWrappingView>
    
    public let configuration: _AppKitOrUIKitHostingPopoverConfiguration
    
    private weak var _rightfulKeyWindow: NSWindow?
    private weak var _rightfulFirstResponder: AppKitOrUIKitResponder?
    
    public private(set) var _detachedWindow: AppKitOrUIKitHostingWindow<Content>?
    
    private var _contentViewController: _ContentViewControllerType {
        if let contentViewController = contentViewController {
            return contentViewController as! _ContentViewControllerType
        } else {
            let result = _ContentViewControllerType(
                mainView: _AppKitOrUIKitHostingWindowContent(
                    window: nil,
                    popover: self,
                    content: rootView
                )
            )
            
            result._SwiftUIX_parentNSPopover = self
            
            self.contentViewController = result
            
            assert(result.mainView._popover != nil)
            
            result.mainView.initialized = true
            
            return result
        }
    }
    
    public var rootView: Content {
        didSet {
            _contentViewController.mainView.content = rootView
        }
    }
    
    @objc open var _SwiftUIX_wantsFixForTransientNSPopover: Bool {
        guard isShown, contentViewController?.view.window != nil else {
            return false
        }
        
        return self.behavior == .transient
    }
        
    public init(
        rootView: Content,
        configuration: _AppKitOrUIKitHostingPopoverConfiguration = nil
    ) {
        self.rootView = rootView
        self.configuration = configuration
        
        super.init()
        
        self.animates = true
        self.delegate = self
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
        guard !_contentViewController.mainView.isEmptyView else {
            return
        }
        
        DispatchQueue.asyncOnMainIfNecessary(force: _sizeContentToFit()) {
            _showWellSized(
                relativeTo: positioningRect,
                of: positioningView,
                preferredEdge: preferredEdge
            )
            
            assert(self._contentViewController.mainView._popover != nil)
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
        _detachedWindow?._SwiftUIX_dismiss()
        _detachedWindow = nil

        _rightfulKeyWindow = NSWindow._firstKeyInstance
        _rightfulFirstResponder = NSWindow._firstKeyInstance?.firstResponder
        
        if self.behavior == .transient {
            self.behavior = .applicationDefined
            self.behavior = .transient
        }
        
        if let positioningViewWindow = positioningView.window {
            assert(!positioningViewWindow.isHidden)
            assert(positioningViewWindow.isVisible)
        }
        
        super.show(
            relativeTo: positioningRect,
            of: positioningView,
            preferredEdge: preferredEdge
        )
        
        if self.behavior == .transient {
            DispatchQueue.main.async {
                self._SwiftUIX_applyFixForTransientNSPopover()
            }
        }
    }
    
    override open func close() {
        _cleanUpPostShow()
        
        super.close()
        
        self.contentViewController = nil
        
    }
    
    override open func performClose(_ sender: Any?) {
        _cleanUpPostShow()
        
        super.performClose(sender)
    }
    
    override open func _SwiftUIX_layoutImmediately() {
        _contentViewController.view.layout()
    }
    
    override open func _SwiftUIX_dismiss() {
        guard isShown else {
            return
        }
        
        performClose(nil)
    }
    
    deinit {
        self.contentViewController = nil
    }
    
    override open func _SwiftUIX_applyFixForTransientNSPopover() {
        guard _SwiftUIX_wantsFixForTransientNSPopover, let popoverWindow = self.contentViewController?.view.window else {
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
    
    // MARK: - NSPopoverDelegate -
    
    public func popoverDidShow(
        _ notification: Notification
    ) {
        _SwiftUIX_applyFixForTransientNSPopover()
    }
    
    public func popoverDidClose(
        _ notification: Notification
    ) {
        _cleanUpPostShow()
        
        contentViewController = nil
    }
    
    public func popoverShouldDetach(
        _ popover: NSPopover
    ) -> Bool {
        _SwiftUIX_hostingPopoverPreferences.isDetachable
    }
    
    public func detachableWindow(
        for popover: NSPopover
    ) -> NSWindow? {
        _SwiftUIX_detachWindow()
    }
    
    public func _SwiftUIX_detachWindow() -> AppKitOrUIKitHostingWindow<Content>? {
        if let _detachedWindow {
            return _detachedWindow
        } else {
            let contentViewController = _contentViewController
                        
            self._objectWillChange_send()
            
            let content = contentViewController.mainView.content
            
            let window = AppKitOrUIKitHostingWindow(
                rootView: content,
                style: .default
            )
            
            self._detachedWindow = window
            
            if #available(macOS 14.0, *) {
                NSApplication.shared.activate()
            } else {
                NSApplication.shared.activate(ignoringOtherApps: true)
            }
            
            return window
        }
    }
    
    override open func _SwiftUIX_detachedWindowDidClose() {
        self._detachedWindow = nil
    }
    
    // MARK: - Internal
    
    private func _cleanUpPostShow() {
        _rightfulKeyWindow = nil
        _rightfulFirstResponder = nil
    }
    
    @discardableResult
    public func _sizeContentToFit() -> Bool {
        guard !_contentViewController.mainView.isEmptyView else {
            return true
        }
        
        let _contentViewController: CocoaHostingController = _contentViewController
        
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
}

#endif

#endif
