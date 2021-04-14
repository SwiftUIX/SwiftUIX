//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct AnyPresentationView: View {
    public let base: _opaque_View
    
    private var environmentBuilder: EnvironmentBuilder
    
    public private(set) var name: ViewName?
    public private(set) var id: AnyHashable?
    public private(set) var popoverAttachmentAnchorBounds: CGRect?
    public private(set) var preferredSourceViewName: ViewName?
    public private(set) var modalPresentationStyle: ModalPresentationStyle = .automatic
    public private(set) var hidesBottomBarWhenPushed: Bool = false
    
    public var body: some View {
        base
            .eraseToAnyView()
            .mergeEnvironmentBuilder(environmentBuilder)
            .modifier(_ResolveAppKitOrUIKitViewController())
    }
    
    public init<V: View>(_ view: V) {
        if let view = view as? AnyPresentationView {
            self = view
        } else {
            self.base = (view as? _opaque_View) ?? view.eraseToAnyView()
            self.environmentBuilder = .init()
        }
    }
}

// MARK: - Conformances -

extension AnyPresentationView: _opaque_View {
    public func _opaque_getViewName() -> ViewName? {
        name
    }
}

// MARK: - API -

extension AnyPresentationView {
    public func name(_ name: ViewName?) -> Self {
        then({ $0.name = name ?? $0.name })
    }
    
    public func popoverAttachmentAnchorBounds(_ bounds: CGRect?) -> Self {
        then({ $0.popoverAttachmentAnchorBounds = bounds })
    }
    
    public func preferredSourceViewName(_ name: ViewName) -> Self {
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
    public func mergeEnvironmentBuilder(_ builder: EnvironmentBuilder) -> Self {
        then({ $0.environmentBuilder.merge(builder) })
    }
    
    public mutating func mergeEnvironmentBuilderInPlace(_ builder: EnvironmentBuilder) {
        self = mergeEnvironmentBuilder(builder)
    }
}
