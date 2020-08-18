//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct EnvironmentalAnyView: View {
    public let base: _opaque_View
    
    private var environmentBuilder: EnvironmentBuilder
    
    private var _name: ViewName?
    
    private var _onPresentImpl: (() -> Void)?
    private var _onDismissImpl: (() -> Void)?
    
    private var _modalPresentationStyle: ModalPresentationStyle?
    private var _isModalPresentationAnimated: Bool?
    private var _isModalDismissableImpl: (() -> Bool)?
    
    private var _hidesBottomBarWhenPushed: Bool?
    
    public var body: some View {
        base.eraseToAnyView().mergeEnvironmentBuilder(environmentBuilder)
    }
    
    public init<V: View>(_ view: V) {
        if let view = view as? EnvironmentalAnyView {
            self = view
        } else {
            self.base = (view as? _opaque_View) ?? view.eraseToAnyView()
            self.environmentBuilder = .init()
        }
    }
}

// MARK: - Protocol Implementations -

extension EnvironmentalAnyView: _opaque_View {
    public func _opaque_getViewName() -> ViewName? {
        _name ?? base._opaque_getViewName()
    }
}

extension EnvironmentalAnyView: ModalPresentationView {
    public var preferredSourceViewName: ViewName? {
        (base as? _opaque_ModalPresentationView)?.preferredSourceViewName
    }
    
    public var presentationEnvironmentBuilder: EnvironmentBuilder? {
        (base as? _opaque_ModalPresentationView)?.presentationEnvironmentBuilder
    }
    
    public var presentationStyle: ModalPresentationStyle {
        _modalPresentationStyle ?? (base as? _opaque_ModalPresentationView)?.presentationStyle ?? .automatic
    }
    
    public var isModalPresentationAnimated: Bool {
        _isModalPresentationAnimated ?? (base as? _opaque_ModalPresentationView)?.isModalPresentationAnimated ?? true
    }
    
    public var isModalDismissable: Bool {
        _isModalDismissableImpl?() ?? (base as? _opaque_ModalPresentationView)?.isModalDismissable ?? true
    }
    
    public func onPresent() {
        _onPresentImpl?()
        (base as? _opaque_ModalPresentationView)?.onPresent()
    }
    
    public func onDismiss() {
        _onDismissImpl?()
        (base as? _opaque_ModalPresentationView)?.onDismiss()
    }
}

extension EnvironmentalAnyView: NavigatableView {
    public var hidesBottomBarWhenPushed: Bool {
        _hidesBottomBarWhenPushed ?? (base as? _opaque_NavigatableView)?.hidesBottomBarWhenPushed ?? false
    }
}

// MARK: - API -

extension EnvironmentalAnyView {
    public func mergeEnvironmentBuilder(_ builder: EnvironmentBuilder) -> Self {
        then({ $0.environmentBuilder.merge(builder) })
    }
    
    public mutating func mergeEnvironmentBuilderInPlace(_ builder: EnvironmentBuilder) {
        self = mergeEnvironmentBuilder(builder)
    }
}

extension EnvironmentalAnyView {
    public func name(_ name: ViewName?) -> Self {
        then({ $0._name = name })
    }
}

extension EnvironmentalAnyView {
    public func onPresent(perform action: @escaping () -> Void) -> Self {
        then({ $0._onPresentImpl = action })
    }
    
    public func onDismiss(perform action: @escaping () -> Void) -> Self {
        then({ $0._onDismissImpl = action })
    }
}

extension EnvironmentalAnyView {
    public func modalPresentationStyle(_ style: ModalPresentationStyle) -> Self {
        then({ $0._modalPresentationStyle = style })
    }
    
    public func isModalDismissable(_ dismissable: Bool) -> Self {
        then({ $0._isModalDismissableImpl = { dismissable } })
    }
    
    public func isModalDismissable(_ dismissable: @escaping () -> Bool) -> Self {
        then({ $0._isModalDismissableImpl = dismissable })
    }
    
    public func isModalPresentationAnimated(_ animated: Bool) -> Self {
        then({ $0._isModalPresentationAnimated = animated })
    }
}

extension EnvironmentalAnyView {
    public func hidesBottomBarWhenPushed(_ hidesBottomBarWhenPushed: Bool) -> Self {
        then({ $0._hidesBottomBarWhenPushed = hidesBottomBarWhenPushed })
    }
}
