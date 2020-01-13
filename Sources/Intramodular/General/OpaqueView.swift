//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A (better) type-erased `View`.
public struct OpaqueView: CustomStringConvertible, View {
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
        if let view = view as? OpaqueView {
            self = view
        } else {
            self.base = view.eraseToAnyView()
            self.baseType = .init(type(of: view))
            self.name = (view as? opaque_NamedView)?.name
            self.environment = environment
        }
    }
    
    public var body: some View {
        base.environment(environment)
    }
}

// MARK: - API -

extension View {
    public func eraseToOpaqueView() -> OpaqueView {
        return .init(self)
    }
}
