//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import SwiftUI

@_documentation(visibility: internal)
public struct AppKitOrUIKitViewAdaptor<Base: AppKitOrUIKitView>: AppKitOrUIKitViewRepresentable {
#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
    public typealias UIViewType = Base
#elseif os(macOS)
    public typealias NSViewType = Base
#endif
    
    public typealias AppKitOrUIKitViewType = Base
    
    fileprivate let _makeView: (Context) -> AppKitOrUIKitViewType
    fileprivate let _updateView: (AppKitOrUIKitViewType, Context) -> ()
    fileprivate let _sizeThatFits: ((_SwiftUIX_ProposedSize, AppKitOrUIKitViewType, Context) -> CGSize?)?
    
    public init(
        _ makeView: @escaping () -> AppKitOrUIKitViewType
    ) {
        self._makeView = { _ in makeView() }
        self._updateView = { _, _ in }
        self._sizeThatFits = nil
    }
    
    public func makeAppKitOrUIKitView(
        context: Context
    ) -> AppKitOrUIKitViewType {
        _makeView(context)
    }
    
    public func updateAppKitOrUIKitView(
        _ view: AppKitOrUIKitViewType,
        context: Context
    ) {
        _updateView(view, context)
    }
}

#if os(macOS)
extension AppKitOrUIKitViewAdaptor {
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    public func sizeThatFits(
        _ proposal: ProposedViewSize,
        nsView: Base,
        context: Context
    ) -> CGSize? {
        if let _sizeThatFits {
            return _sizeThatFits(.init(proposal), nsView, context)
        } else {
            return nsView.intrinsicContentSize
        }
    }
}
#endif

#endif
