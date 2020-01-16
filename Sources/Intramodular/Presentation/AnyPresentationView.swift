//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A type-erased `View` suitable for presentation purposes.
public struct AnyPresentationView: CustomStringConvertible, View {
    private let base: AnyView
    private let baseType: ObjectIdentifier
    private let environment: EnvironmentValues?
    
    public let name: ViewName?
    
    public var description: String {
        if let name = name {
            return "\(name) (\(base)"
        } else {
            return String(describing: base)
        }
    }
    
    public init<V: View>(_ view: V, environment: EnvironmentValues? = nil) {
        if let view = view as? AnyPresentationView {
            self = view
        } else {
            self.base = view.eraseToAnyView()
            self.baseType = .init(type(of: view))
            self.name = (view as? opaque_NamedView)?.name
            self.environment = environment
        }
    }
    
    public var body: some View {
        base
    }
}

// MARK: - API -

extension View {
    public func eraseToAnyPresentationView() -> AnyPresentationView {
        return .init(self)
    }
}
