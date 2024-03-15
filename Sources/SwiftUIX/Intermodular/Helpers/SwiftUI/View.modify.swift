//
// Copyright (c) Vatsal Manot
//

import SwiftUI

extension View {
    @ViewBuilder
    public func modify<T: View>(
        @ViewBuilder transform: (Self) -> T
    ) -> some View {
        transform(self)
    }
    
    /// Modifies the view based on a predicate.
    @ViewBuilder
    public func modify<T: View>(
        if predicate: Bool,
        @ViewBuilder transform: (Self) -> T
    ) -> some View {
        if predicate {
            transform(self)
        } else {
            self
        }
    }
    
    /// Modifies the view based on a predicate.
    @ViewBuilder
    public func modify<T: View, U: Equatable>(
        if keyPath: KeyPath<EnvironmentValues, U>,
        equals comparate: U,
        @ViewBuilder transform: @escaping (Self) -> T
    ) -> some View {
        EnvironmentValueAccessView(keyPath) { value in
            if value == comparate {
                transform(self)
            } else {
                self
            }
        }
    }
    
    /// Modifies the view based on a predicate.
    @ViewBuilder
    public func modify<T: View>(
        if idiom: UserInterfaceIdiom,
        @ViewBuilder transform: (Self) -> T
    ) -> some View {
        if idiom == .current {
            transform(self)
        } else {
            self
        }
    }
}

extension View {
    /// Resolves and applies a modifier to a view and returns a new view.
    @_disfavoredOverload
    public func modify<T: ViewModifier>(
        _ modifier: () -> T
    ) -> ModifiedContent<Self, T> {
        self.modifier(modifier())
    }
    
    /// Modifies the view based on a predicate.
    @ViewBuilder
    public func modify<Value>(
        forUnwrapped value: Value?,
        transform: (Value) -> AnyViewModifier
    ) -> some View {
        if let value {
            modifier(transform(value))
        } else {
            self
        }
    }
}
