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
    case disableResponderChain
    case suppressRelayout
}

open class _CocoaHostingView<Content: View>: AppKitOrUIKitHostingView<CocoaHostingControllerContent<Content>>, _CocoaHostingControllerOrView {
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
    
#if os(macOS)
    @_optimize(speed)
    @inline(__always)
    override open var needsLayout: Bool {
        get {
            super.needsLayout
        } set {
            super.needsLayout = newValue
        }
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
        if _hostingViewConfigurationFlags.contains(.disableResponderChain) {
            return false
        }
        
        return super.becomeFirstResponder()
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
        guard !_hostingViewConfigurationFlags.contains(.suppressRelayout) else {
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
        guard !_hostingViewConfigurationFlags.contains(.suppressRelayout) else {
            return
        }
        
        super.layout()
    }
    
    @_optimize(speed)
    override open func resizeSubviews(
        withOldSize oldSize: NSSize
    ) {
        guard !_hostingViewConfigurationFlags.contains(.suppressRelayout) else {
            return
        }
        
        super.resizeSubviews(withOldSize: oldSize)
    }
    
    @_optimize(speed)
    override open func resize(
        withOldSuperviewSize oldSize: NSSize
    ) {
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
