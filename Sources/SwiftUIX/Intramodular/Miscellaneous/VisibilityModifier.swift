//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A modifier that controls a view's visibility.
public struct _VisibilityModifier: ViewModifier {
    @usableFromInline
    let isVisible: Bool
    
    @usableFromInline
    init(isVisible: Bool) {
        self.isVisible = isVisible
    }
    
    @inlinable
    public func body(content: Content) -> some View {
        content.opacity(isVisible ? 1 : 0)
    }
}

// MARK: - Helpers

extension View {
    /// Sets a view's visibility.
    ///
    /// The view still retains its frame.
    @inlinable
    public func visible(_ isVisible: Bool = true) -> some View {
        modifier(_VisibilityModifier(isVisible: isVisible))
    }

    /// Sets a view's visibility.
    ///
    /// The view still retains its frame.
    @inlinable
    public func visible(_ isVisible: Bool, animation: Animation?) -> some View {
        modifier(_VisibilityModifier(isVisible: isVisible))
            .animation(animation, value: isVisible)
    }
}
