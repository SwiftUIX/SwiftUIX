//
// Copyright (c) Vatsal Manot
//

import SwiftUI

extension View {
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
