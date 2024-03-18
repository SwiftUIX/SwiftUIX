//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS)

import Combine
import Swift
import SwiftUI

@frozen
public enum _CocoaHostingViewStateFlag {
    case didJustMoveToSuperview
}

@frozen
public enum _CocoaHostingViewConfigurationFlag {
    case invisible
    case disableResponderChain
    case suppressRelayout
    case suppressIntrinsicContentSizeInvalidation
}

open class _CocoaHostingView<Content: View>: AppKitOrUIKitHostingView<CocoaHostingControllerContent<Content>>, _CocoaHostingControllerOrView {
    public typealias MainView = Content
    public typealias RootView = CocoaHostingControllerContent<Content>
    
    public var _SwiftUIX_cancellables: [AnyCancellable] = []
    public var _observedPreferenceValues = _ObservedPreferenceValues()
    
    public var _hostingViewConfigurationFlags: Set<_CocoaHostingViewConfigurationFlag> = []
    public var _hostingViewStateFlags: Set<_CocoaHostingViewStateFlag> = []
    
    public var _configuration: CocoaHostingControllerConfiguration = .init() {
        didSet {
            rootView.parentConfiguration = _configuration
        }
    }
    
    @_optimize(speed)
    @inline(__always)
    public var mainView: Content {
        get {
            rootView.content
        } set {
            rootView.content = newValue
        }
    }
    
    public var _overrideSizeForUpdateConstraints: OptionalDimensions = nil
    
#if os(macOS)
    @_optimize(speed)
    @inline(__always)
    override open var needsLayout: Bool {
        get {
            super.needsLayout
        } set {
            guard !_hostingViewConfigurationFlags.contains(.invisible) else {
                return
            }
            
            guard !_hostingViewConfigurationFlags.contains(.suppressRelayout) else {
                return
            }
            
            super.needsLayout = newValue
        }
    }
    
    @_optimize(speed)
    @inline(__always)
    override open var needsUpdateConstraints: Bool {
        get {
            super.needsUpdateConstraints
        } set {
            guard !_hostingViewConfigurationFlags.contains(.invisible) else {
                return
            }
            
            super.needsUpdateConstraints = newValue
        }
    }
    
    override open func updateConstraints() {
        if let overrideWidth = _overrideSizeForUpdateConstraints.width {
            if let constraint = constraints.first(where: { $0.firstAttribute == .width || $0.secondAttribute == .width && $0.constant == overrideWidth }), constraint.constant != overrideWidth {
                constraint.constant = overrideWidth
            }
        }

        if let overrideHeight = _overrideSizeForUpdateConstraints.height {
            if let constraint = constraints.first(where: { $0.firstAttribute == .height || $0.secondAttribute == .height && $0.constant == overrideHeight }), constraint.constant != overrideHeight {
                constraint.constant = overrideHeight
            }
        }
        
        self._overrideSizeForUpdateConstraints = nil

        super.updateConstraints()
    }
    
    func copyLayoutConstraint(_ constraint: NSLayoutConstraint, constant: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(
            item: constraint.firstItem!,
            attribute: constraint.firstAttribute,
            relatedBy: constraint.relation,
            toItem: constraint.secondItem,
            attribute: constraint.secondAttribute,
            multiplier: constraint.multiplier,
            constant: constant
        )
    }
#endif
    
#if os(macOS)
    override open var acceptsFirstResponder: Bool {
        if _hostingViewConfigurationFlags.contains(.disableResponderChain) {
            return false
        }
        
        return true
    }
#endif
    
#if os(macOS)
    override open func becomeFirstResponder() -> Bool {
        guard !_hostingViewConfigurationFlags.contains(.invisible) else {
            return false
        }
        
        if _hostingViewConfigurationFlags.contains(.disableResponderChain) {
            return false
        }
        
        return super.becomeFirstResponder()
    }
#endif
    
#if os(macOS)
    override open func draw(_ dirtyRect: NSRect) {
        guard !_hostingViewConfigurationFlags.contains(.invisible) else {
            return
        }
        
        super.draw(dirtyRect)
    }
    
    open override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        guard !_hostingViewConfigurationFlags.contains(.invisible) else {
            return false
        }
        
        return super.acceptsFirstMouse(for: event)
    }
    
    override open func isMousePoint(_ point: NSPoint, in rect: NSRect) -> Bool {
        guard !_hostingViewConfigurationFlags.contains(.invisible) else {
            return false
        }
        
        return super.isMousePoint(point, in: rect)
    }
    
    override open func setNeedsDisplay(_ invalidRect: NSRect) {
        guard !_hostingViewConfigurationFlags.contains(.invisible) else {
            return
        }
        
        super.setNeedsDisplay(invalidRect)
    }
    
    override open func hitTest(_ point: NSPoint) -> NSView? {
        guard !_hostingViewConfigurationFlags.contains(.invisible) else {
            return nil
        }
        
        return super.hitTest(point)
    }
    
    override open func cursorUpdate(with event: NSEvent) {
        guard !_hostingViewConfigurationFlags.contains(.invisible) else {
            return
        }
        
        return super.cursorUpdate(with: event)
    }
    
    override open func scrollWheel(with event: NSEvent) {
        guard !_hostingViewConfigurationFlags.contains(.invisible) else {
            return
        }
        
        return super.scrollWheel(with: event)
    }
    
    override open func wantsForwardedScrollEvents(for axis: NSEvent.GestureAxis) -> Bool {
        return super.wantsForwardedScrollEvents(for: axis)
    }
    
    override open func display() {
        guard !_hostingViewConfigurationFlags.contains(.invisible) else {
            return
        }
        
        super.display()
    }
    
    override open func touchesBegan(with event: NSEvent) {
        guard !_hostingViewConfigurationFlags.contains(.invisible) else {
            return
        }
        
        return super.touchesBegan(with: event)
    }
    
    override open func touchesMoved(with event: NSEvent) {
        guard !_hostingViewConfigurationFlags.contains(.invisible) else {
            return
        }
        
        return super.touchesMoved(with: event)
    }
    
    override open func touchesEnded(with event: NSEvent) {
        guard !_hostingViewConfigurationFlags.contains(.invisible) else {
            return
        }
        
        return super.touchesEnded(with: event)
    }
#endif
    
    public init(mainView: Content) {
        super.init(
            rootView: .init(
                parent: nil,
                parentConfiguration: _configuration,
                content: mainView
            )
        )
        
        self.rootView.parent = self
        
        _assembleCocoaHostingView()
    }
    
    @inline(__always)
    public required init(rootView: RootView) {
        super.init(rootView: rootView)
        
        assert(self.rootView.parent == nil)
        
        self.rootView.parent = self
        
        _assembleCocoaHostingView()
    }
    
    public required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func _assembleCocoaHostingView() {
        
    }
    
    open func _refreshCocoaHostingView() {
        
    }
    
    override open func invalidateIntrinsicContentSize() {
        guard !_hostingViewConfigurationFlags.contains(.invisible) else {
            return
        }
        
        guard !_hostingViewConfigurationFlags.contains(.suppressRelayout) else {
            return
        }
        
        guard !_hostingViewConfigurationFlags.contains(.suppressIntrinsicContentSizeInvalidation) else {
            return
        }
        
        super.invalidateIntrinsicContentSize()
    }
    
#if os(macOS)
    override open func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
    }
    
    override open func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        
        if superview != nil {
            _hostingViewStateFlags.insert(.didJustMoveToSuperview)
        } else {
            _hostingViewStateFlags.remove(.didJustMoveToSuperview)
        }
        
        DispatchQueue.main.async {
            self._hostingViewStateFlags.remove(.didJustMoveToSuperview)
        }
    }
    
    @_optimize(speed)
    override open func layout() {
        guard !_hostingViewConfigurationFlags.contains(.invisible) else {
            return
        }
        
        guard !_hostingViewConfigurationFlags.contains(.suppressRelayout) else {
            return
        }
        
        super.layout()
    }
    
    @_optimize(speed)
    override open func resizeSubviews(
        withOldSize oldSize: NSSize
    ) {
        guard !_hostingViewConfigurationFlags.contains(.invisible) else {
            return
        }
        
        guard !_hostingViewConfigurationFlags.contains(.suppressRelayout) else {
            return
        }
        
        super.resizeSubviews(withOldSize: oldSize)
    }
    
    @_optimize(speed)
    override open func resize(
        withOldSuperviewSize oldSize: NSSize
    ) {
        guard !_hostingViewConfigurationFlags.contains(.invisible) else {
            return
        }
        
        guard !_hostingViewConfigurationFlags.contains(.suppressRelayout) else {
            return
        }
        
        super.resize(withOldSuperviewSize: oldSize)
    }
#endif
}

extension _CocoaHostingView {
    @_optimize(speed)
    @_transparent
    @inlinable
    @inline(__always)
    public func withCriticalScope<Result>(
        _ flags: Set<_CocoaHostingViewConfigurationFlag>,
        perform action: () -> Result
    ) -> Result {
        let currentFlags = self._hostingViewConfigurationFlags
        
        defer {
            self._hostingViewConfigurationFlags = currentFlags
        }
        
        self._hostingViewConfigurationFlags.formUnion(flags)
        
        return action()
    }
}

// MARK: - WIP

#if os(macOS)
extension _CocoaHostingView {
    @_spi(Internal)
    public func _setUpExperimentalSizeSync() {
        NotificationCenter.default.addObserver(
            forName: NSView.frameDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let `self` = self else {
                return
            }
            
            guard let view = notification.object as? NSView, view.superview == self else {
                return
            }
            
            guard view.frame.size._isNormal, self.frame.size._isNormal else {
                return
            }
            
            // TODO: Implement
        }
    }
}
#endif

#endif
