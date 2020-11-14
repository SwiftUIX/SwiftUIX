//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct AnyPresentationView: View {
    public let base: _opaque_View
    private var environmentBuilder: EnvironmentBuilder
    private var _name: ViewName?
    private var _modalPresentationStyle: ModalPresentationStyle?
    private var _hidesBottomBarWhenPushed: Bool?
    
    public var body: some View {
        base.eraseToAnyView().mergeEnvironmentBuilder(environmentBuilder)
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

// MARK: - Protocol Conformances -

extension AnyPresentationView: _opaque_View {
    public func _opaque_getViewName() -> ViewName? {
        _name ?? base._opaque_getViewName()
    }
}

extension AnyPresentationView: ModalPresentationView {
    public var preferredSourceViewName: ViewName? {
        (base as? _opaque_ModalPresentationView)?.preferredSourceViewName
    }
    
    public var presentationStyle: ModalPresentationStyle {
        _modalPresentationStyle ?? (base as? _opaque_ModalPresentationView)?.presentationStyle ?? .automatic
    }
}

extension AnyPresentationView: NavigatableView {
    public var hidesBottomBarWhenPushed: Bool {
        _hidesBottomBarWhenPushed ?? (base as? _opaque_NavigatableView)?.hidesBottomBarWhenPushed ?? false
    }
}

// MARK: - API -

extension AnyPresentationView {
    public func mergeEnvironmentBuilder(_ builder: EnvironmentBuilder) -> Self {
        then({ $0.environmentBuilder.merge(builder) })
    }
    
    public mutating func mergeEnvironmentBuilderInPlace(_ builder: EnvironmentBuilder) {
        self = mergeEnvironmentBuilder(builder)
    }
}

extension AnyPresentationView {
    public func name(_ name: ViewName?) -> Self {
        then({ $0._name = name })
    }
}

extension AnyPresentationView {
    public func modalPresentationStyle(_ style: ModalPresentationStyle) -> Self {
        then({ $0._modalPresentationStyle = style })
    }
}

extension AnyPresentationView {
    public func hidesBottomBarWhenPushed(_ hidesBottomBarWhenPushed: Bool) -> Self {
        then({ $0._hidesBottomBarWhenPushed = hidesBottomBarWhenPushed })
    }
}
