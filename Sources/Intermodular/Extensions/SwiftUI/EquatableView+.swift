//
// Copyright (c) Vatsal Manot
//

import SwiftUI

extension View {
    /// Prevents the view from updating its child view when its new given value is the same as its old given value.
    public func equatable<V: Equatable>(by value: V) -> some View {
        _AdHocEquatableView(content: self, value: value)
            .equatable()
    }
}

// MARK: - Auxiliary Implementation -

private struct _AdHocEquatableView<Content: View, Value: Equatable>: Equatable, View {
    let content: Content
    let value: Value
    
    var body: some View {
        content
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value
    }
}
