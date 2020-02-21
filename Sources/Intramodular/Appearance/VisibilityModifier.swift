//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A modifier that controls a view's visibility.
struct VisibilityModifier: ViewModifier {
    let isVisible: Bool
    
    func body(content: Content) -> some View {
        content.opacity(isVisible ? 1 : 0)
    }
}

// MARK: - Helpers -

extension View {
    /// Sets a view's visibility.
    ///
    /// The view still retains its frame.
    public func visible(_ isVisible: Bool = true) -> some View {
        modifier(VisibilityModifier(isVisible: isVisible))
    }
}
