//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct EnvironmentalAnyView: View {
    public let base: opaque_View
    
    private var environmentBuilder: EnvironmentBuilder
    
    public init<V: View>(_ view: V) {
        if let view = view as? EnvironmentalAnyView {
            self = view
        } else {
            self.base = (view as? opaque_View) ?? view.eraseToAnyView()
            self.environmentBuilder = .init()
        }
    }
    
    public var body: some View {
        base.eraseToAnyView().mergeEnvironmentBuilder(environmentBuilder)
    }
    
    public func opaque_getViewName() -> ViewName? {
        base.opaque_getViewName()
    }
}

extension EnvironmentalAnyView {
    public func mergeEnvironmentBuilder(_ builder: EnvironmentBuilder) -> Self {
        then({ $0.environmentBuilder.merge(builder) })
    }
    
    public mutating func mergeEnvironmentBuilderInPlace(_ builder: EnvironmentBuilder) {
        self = mergeEnvironmentBuilder(builder)
    }
}

// MARK: - Protocol Implementations -

extension EnvironmentalAnyView: ModalPresentationView {
    public var presentationEnvironmentBuilder: EnvironmentBuilder? {
        (base as? opaque_ModalPresentationView)?.presentationEnvironmentBuilder
    }
    
    public var presentationStyle: ModalViewPresentationStyle {
        (base as? opaque_ModalPresentationView)?.presentationStyle ?? .automatic
    }
}

extension EnvironmentalAnyView: NavigatableView {
    public var hidesBottomBarWhenPushed: Bool {
        (base as? opaque_NavigatableView)?.hidesBottomBarWhenPushed ?? false
    }
}
