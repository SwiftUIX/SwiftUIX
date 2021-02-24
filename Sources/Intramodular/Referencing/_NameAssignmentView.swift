//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A view modifier that attaches a view name.
fileprivate struct _NameAssignmentView<Content: View>: View {
    private let content: Content
    private let name: ViewName
    
    init(content: Content, name: ViewName) {
        self.content = content
        self.name = name
    }
    
    var body: some View {
        content
            .environment(\._name, name)
            .background(
                GeometryReader { geometry in
                    ZeroSizeView().anchorPreference(
                        key: _NamedViewDescription.PreferenceKey.self,
                        value: .bounds
                    ) {
                        .init(
                            _NamedViewDescription(
                                name: name,
                                bounds: $0,
                                globalBounds: geometry.frame(in: .global)
                            )
                        )
                    }
                }
            )
    }
}

// MARK: - API -

extension View {
    /// Set a name for `self`.
    public func name(_ name: ViewName) -> some View {
        _NameAssignmentView(content: self, name: name.withViewType(type(of: self)))
    }
    
    /// Set a name for `self`.
    public func name<H: Hashable>(_ name: H) -> some View {
        self.name(ViewName(name))
    }
}
