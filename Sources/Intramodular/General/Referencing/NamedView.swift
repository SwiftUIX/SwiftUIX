//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public protocol opaque_NamedView {
    var name: ViewName { get }
}

public struct NamedView<V: View>: opaque_NamedView, View {
    public let view: V
    public let name: ViewName
    
    fileprivate init(view: V, name: ViewName) {
        self.view = view
        self.name = name
    }
    
    public var body: some View {
        view.environment(\.viewName, name).anchorPreference(
            key: ArrayReducePreferenceKey<ViewNamePreferenceKeyValue>.self,
            value: .bounds
        ) {
            [.init(name: self.name, bounds: $0)]
        }
        .transformEnvironment(\.environmentBuilder) {
            $0.setViewName(self.name)
        }
    }
}

// MARK: - API -

extension View {
    /// Set a name for `self`.
    public func name(_ name: ViewName) -> NamedView<Self> {
        NamedView(view: self, name: name)
    }

    /// Set a name for `self`.
    public func name<H: Hashable>(_ name: H) -> NamedView<Self> {
        self.name(ViewName(name))
    }
}
