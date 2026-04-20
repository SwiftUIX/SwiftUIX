//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS)

import _SwiftUIX
import Combine
import Swift
import SwiftUI

public protocol _CocoaSwiftUIViewHosting<HostedView> {
    associatedtype HostedView: SwiftUI.View
    
    func updateHostedView(
        _ view: HostedView,
        context: _CocoaSwiftUIViewHostingUpdateContext?
    )
    
    func eraseToAnyAnyCocoaSwiftUIViewHostingObject() -> _AnyCocoaSwiftUIViewHostingObject<HostedView>
}

public protocol _CocoaSwiftUIViewHostingAppKitOrUIKitView<HostedView>: _CocoaSwiftUIViewHosting<Self.HostedView>, AppKitOrUIKitView {
    
}

public struct _CocoaSwiftUIViewHostingUpdateContext {
    public var cocoaHostingViewConfigurationFlags: Set<_CocoaHostingViewConfigurationFlag> = []
    
    public init() {
        
    }
}

// MARK: - Default Implementation

extension _CocoaSwiftUIViewHosting {
    public func eraseToAnyAnyCocoaSwiftUIViewHostingObject() -> _AnyCocoaSwiftUIViewHostingObject<HostedView> {
        _AnyCocoaSwiftUIViewHostingObject(wrapping: self)
    }
}

// MARK: - Conformances

#if os(iOS) || os(tvOS) || os(visionOS)
@available(iOS 16.0, tvOS 16.0, *)
extension _SwiftUIX_AppKitOrUIKitHostingView {
    public typealias HostedView = Content
    
    public func updateHostedView(
        _ view: Content,
        context: _CocoaSwiftUIViewHostingUpdateContext?
    ) {
        guard let context else {
            self.rootView = view
            
            return
        }
        
        assert(context.cocoaHostingViewConfigurationFlags.isEmpty, "cocoaHostingViewConfigurationFlags unsupported on _SwiftUIX_AppKitOrUIKitHostingView")
        
        self.rootView = view
    }
}
#endif

#if os(macOS)
extension _SwiftUIX_AppKitOrUIKitHostingView {
    public typealias HostedView = Content
    
    public func updateHostedView(
        _ view: Content,
        context: _CocoaSwiftUIViewHostingUpdateContext?
    ) {
        guard let context else {
            self.rootView = view
            
            return
        }
        
        assert(context.cocoaHostingViewConfigurationFlags.isEmpty, "cocoaHostingViewConfigurationFlags unsupported on _SwiftUIX_AppKitOrUIKitHostingView")
        
        self.rootView = view
    }
}
#endif


extension _CocoaHostingView {
    public typealias HostedView = Content
    
    public func updateHostedView(
        _ view: Content,
        context: _CocoaSwiftUIViewHostingUpdateContext?
    ) {
        guard let context else {
            self.rootView.content = view
            
            return
        }
        
        withCriticalScope(context.cocoaHostingViewConfigurationFlags) {
            self.rootView.content = view
        }
    }
}

public final class _AnyCocoaSwiftUIViewHostingObject<HostedView: SwiftUI.View>: _CocoaSwiftUIViewHosting {
    public typealias _UnwrappedBaseType = any _CocoaSwiftUIViewHosting<HostedView>
    
    public let base: _UnwrappedBaseType
    
    public init(wrapping base: _UnwrappedBaseType) {
        self.base = base
    }
    
    public func updateHostedView(
        _ view: HostedView,
        context: _CocoaSwiftUIViewHostingUpdateContext?
    ) {
        self.base.updateHostedView(view, context: context)
    }
    
    public func eraseToAnyAnyCocoaSwiftUIViewHostingObject() -> _AnyCocoaSwiftUIViewHostingObject<HostedView> {
        self
    }
    
    public func _unwrapBase() -> _UnwrappedBaseType {
        base
    }
}

#endif
