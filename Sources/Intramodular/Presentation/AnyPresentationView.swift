//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct AnyPresentationView: View {
    enum Base {
        case native(AnyView)
        #if !os(watchOS)
        case appKitOrUIKitViewController(AppKitOrUIKitViewController)
        #endif
    }
    
    var base: Base
    
    var environmentInsertions: EnvironmentInsertions = .init()
    
    public private(set) var name: AnyHashable?
    public private(set) var id: AnyHashable?
    public private(set) var popoverAttachmentAnchorBounds: CGRect?
    public private(set) var preferredSourceViewName: AnyHashable?
    public private(set) var modalPresentationStyle: ModalPresentationStyle = .automatic
    public private(set) var hidesBottomBarWhenPushed: Bool = false
    
    public var body: some View {
        PassthroughView {
            switch base {
                case .native(let view):
                    view
                        .environment(environmentInsertions)
                        ._resolveAppKitOrUIKitViewControllerIfAvailable()
                #if !os(watchOS)
                case .appKitOrUIKitViewController(let viewController):
                    AppKitOrUIKitViewControllerAdaptor(viewController)
                        .environment(environmentInsertions)
                        ._resolveAppKitOrUIKitViewController(with: viewController)
                #endif
            }
        }
    }
    
    public init<V: View>(_ view: V) {
        if let view = view as? AnyPresentationView {
            self = view
        } else {
            self.base = .native((view as? _opaque_View)?.eraseToAnyView() ?? view.eraseToAnyView())
        }
    }
    
    #if !os(watchOS)
    public init(_ viewController: AppKitOrUIKitViewController) {
        self.base = .appKitOrUIKitViewController(viewController)

        #if os(iOS)
        if let transitioningDelegate = viewController.transitioningDelegate {
            self = self.modalPresentationStyle(.custom(transitioningDelegate))
        }
        #endif
    }
    #endif
}

// MARK: - Conformances -

extension AnyPresentationView: _opaque_View {
    public func _opaque_getViewName() -> AnyHashable? {
        name
    }
}

// MARK: - API -

extension AnyPresentationView {
    public func name(_ name: AnyHashable?) -> Self {
        then({ $0.name = name ?? $0.name })
    }
    
    public func popoverAttachmentAnchorBounds(_ bounds: CGRect?) -> Self {
        then({ $0.popoverAttachmentAnchorBounds = bounds })
    }
    
    public func preferredSourceViewName(_ name: AnyHashable) -> Self {
        then({ $0.preferredSourceViewName = name })
    }
    
    public func modalPresentationStyle(_ style: ModalPresentationStyle) -> Self {
        then({ $0.modalPresentationStyle = style })
    }
    
    public func hidesBottomBarWhenPushed(_ hidesBottomBarWhenPushed: Bool) -> Self {
        then({ $0.hidesBottomBarWhenPushed = hidesBottomBarWhenPushed })
    }
}

extension AnyPresentationView {
    public func environment(_ builder: EnvironmentInsertions) -> Self {
        then({ $0.environmentInsertions.merge(builder) })
    }
    
    public mutating func environmentInPlace(_ builder: EnvironmentInsertions) {
        self = environment(builder)
    }
}
