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
    
    @usableFromInline
    init(content: Content, name: ViewName) {
        self.content = content
        self.name = name
    }
    
    @inlinable
    public var body: some View {
        content
            .environment(\.viewName, name)
            .background(GeometryReader { geometry in
                ZeroSizeView().anchorPreference(
                    key: ViewDescription.PreferenceKey.self,
                    value: .bounds
                ) {
                    [
                        .init(
                            name: self.name,
                            bounds: $0,
                            globalBounds: geometry.frame(in: .global)
                        )
                    ]
                }
            })
    }
}

// MARK: - API -

extension View {
    /// Set a name for `self`.
    @inlinable
    public func name(_ name: ViewName) -> NameAssignmentView<Self> {
        .init(content: self, name: name.withViewType(type(of: self)))
    }
    
    /// Set a name for `self`.
    @inlinable
    public func name<H: Hashable>(_ name: H) -> NameAssignmentView<Self> {
        self.name(ViewName(name))
    }
    
    @inlinable
    public func name() -> some View {
        name(ViewName(type(of: self)))
    }
}
