//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Combine
import Swift
import SwiftUI

open class _CocoaHostingView<Content: View>: AppKitOrUIKitHostingView<CocoaHostingControllerContent<Content>>, _CocoaHostingControllerOrView {
    public typealias RootView = CocoaHostingControllerContent<Content>
    
    public var _SwiftUIX_cancellables: [AnyCancellable] = []
    public var _observedPreferenceValues = _ObservedPreferenceValues()

    public var _configuration: CocoaHostingControllerConfiguration = .init() {
        didSet {
            rootView.parentConfiguration = _configuration
        }
    }
        
    public var mainView: Content {
        get {
            rootView.content
        } set {
            rootView.content = newValue
        }
    }
    
    #if os(macOS)
    override open var needsLayout: Bool {
        get {
            super.needsLayout
        } set {
            super.needsLayout = newValue
        }
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
        
        rootView.parent = self
    }
        
    public required init(rootView: RootView) {
        super.init(rootView: rootView)
    }
    
    public required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func invalidateIntrinsicContentSize() {
        super.invalidateIntrinsicContentSize()
    }
    
    #if os(macOS)
    override open func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
    }
    
    override open func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)
    }
    
    override open func layout() {
        super.layout()
    }
    
    override open func layoutSubtreeIfNeeded() {
        super.layoutSubtreeIfNeeded()
    }
    
    override open func resize(withOldSuperviewSize oldSize: NSSize) {
        super.resize(withOldSuperviewSize: oldSize)
    }
    #endif
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
