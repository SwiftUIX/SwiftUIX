//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A view that unwraps an `Optional` to produce some content.
public struct UnwrapOptionalView<Content: View>: View {
    private let content: Content?
    
    public var body: some View {
        content
    }
}

extension UnwrapOptionalView {
    public init<Value>(
        _ value: Optional<Value>,
        @ViewBuilder content: (Value) -> Content
    ) {
        self.content = value.map(content)
    }
    
    public init<Value>(
        _ value: Binding<Optional<Value>>,
        @ViewBuilder content: (Binding<Value>) -> Content
    ) {
        self.content = value.wrappedValue.map { unwrappedValue in
            let binding = Binding(
                get: { value.wrappedValue ?? unwrappedValue },
                set: { newValue in
                    if value.wrappedValue != nil {
                        value.wrappedValue = newValue
                    }
                }
            )
            
            content(binding)
        }
    }
}

extension UnwrapOptionalView {
    public static func ?? <V: View>(lhs: UnwrapOptionalView, rhs: V) -> some View {
        PassthroughView {
            if lhs.content == nil {
                rhs
            } else {
                lhs
            }
        }
    }
    
    public func `else`<V: View>(@ViewBuilder _ view: () -> V) -> some View {
        self ?? view()
    }
    
    public func `else`<V: View>(_ view: V) -> some View {
        self ?? view
    }
}

// MARK: - Supplementary -

extension Optional {
    public func ifSome<Content: View>(
        @ViewBuilder content: (Wrapped) -> Content
    ) -> UnwrapOptionalView<Content> {
        UnwrapOptionalView(self, content: content)
    }
}

extension View {
    public func unwrap<T, V: View>(
        _ value: T?, transform: (T, Self) -> V
    ) -> some View {
        PassthroughView {
            if value != nil {
                transform(value!, self)
            } else {
                self
            }
        }
    }
}
