//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS)

import _SwiftUIX
import Combine
import Swift
import SwiftUI
 
/// A thing that provides some reified `_CocoaSwiftUIViewHosting` thing.
public protocol _CocoaSwiftUIViewHostingViewProvider<HostedView> {
    associatedtype HostedView: SwiftUI.View
    associatedtype WrappedSwiftUIViewHostingType: _CocoaSwiftUIViewHosting<HostedView>
    
    func withUnwrappedSwiftUIViewHostingObject<R>(
        _ body: (WrappedSwiftUIViewHostingType) throws -> R
    ) rethrows -> R
}

extension _CocoaSwiftUIViewHostingViewProvider {
    public func updateHostedView(
        _ view: HostedView,
        context: _CocoaSwiftUIViewHostingUpdateContext?
    ) {
        withUnwrappedSwiftUIViewHostingObject {
            $0.updateHostedView(view, context: context)
        }
    }
}

// MARK: - Conformances

extension _CocoaHostingView: _CocoaSwiftUIViewHostingViewProvider {
    public typealias WrappedSwiftUIViewHostingType = _CocoaHostingView<Content>
    
    public func withUnwrappedSwiftUIViewHostingObject<R>(
        _ body: (_CocoaHostingView<Content>) throws -> R
    ) rethrows -> R {
        try body(self)
    }
}

// MARK: - Auxiliary

public final class _SimpleCocoaSwiftUIViewHostingViewProvider<Wrapped: _CocoaSwiftUIViewHosting> {
    public var wrapped: Wrapped
    
    public init(wrapped: Wrapped) {
        self.wrapped = wrapped
    }
    
    public func withUnwrappedSwiftUIViewHostingObject<R>(
        _ body: (Wrapped) throws -> R
    ) rethrows -> R {
        try body(wrapped)
    }
}

#endif
