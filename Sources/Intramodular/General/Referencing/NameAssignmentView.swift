//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A view modifier that attaches a view name.
public struct NameAssignmentView<Content: View>: NamedView {
    public let content: Content
    public let name: ViewName
    
    fileprivate init(content: Content, name: ViewName) {
        self.content = content
        self.name = name
    }
    
    public var body: some View {
        content.environment(\.viewName, name).anchorPreference(
            key: ArrayReducePreferenceKey<ViewNamePreferenceKeyValue>.self,
            value: .bounds
        ) {
            [.init(name: self.name, bounds: $0)]
        }
    }
}

// MARK: - API -

extension View {
    /// Set a name for `self`.
    public func name(_ name: ViewName) -> NameAssignmentView<Self> {
        .init(content: self, name: name)
    }
    
    /// Set a name for `self`.
    public func name<H: Hashable>(_ name: H) -> NameAssignmentView<Self> {
        self.name(ViewName(name))
    }
}
