//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A view that unwraps an `Optional` to produce some content.
public struct UnwrapOptionalView<Content: View>: View {
    @usableFromInline
    let content: Content?
    
    @inlinable
    public init<Value>(_ value: Optional<Value>, @ViewBuilder content: (Value) -> Content) {
        self.content = value.map(content)
    }
    
    @inlinable
    public var body: some View {
        content
    }
    
    @inlinable
    public static func ?? <V: View>(lhs: UnwrapOptionalView, rhs: V) -> some View {
        Group {
            if lhs.content == nil {
                rhs
            } else {
                lhs
            }
        }
    }
}

extension UnwrapOptionalView {
    @inlinable
    public func `else`<V: View>(@ViewBuilder _ view: () -> V) -> some View {
        self ?? view()
    }
    
    @inlinable
    public func `else`<V: View>(_ view: V) -> some View {
        self ?? view
    }
}

// MARK: - Helpers -

extension Optional {
    @inlinable
    public func ifSome<Content: View>(@ViewBuilder content: (Wrapped) -> Content) -> UnwrapOptionalView<Content> {
        .init(self, content: content)
    }
}

extension View {
    @inlinable
    public func unwrap<T, V: View>(_ value: T?, transform: (T, Self) -> V) -> some View {
        Group {
            if value != nil {
                transform(value!, self)
            } else {
                self
            }
        }
    }
}
