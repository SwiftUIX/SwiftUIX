//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct UnwrapOptionalView<Value, Content: View>: View {
    private let content: Content?
    
    public init(_ value: Optional<Value>, @ViewBuilder content: (Value) -> Content) {
        self.content = value.map(content)
    }
    
    public var body: some View {
        content ?? EmptyView()
    }
    
    public func `else`<V: View>(@ViewBuilder _ view: () -> V) -> some View {
        self ?? view()
    }
    
    public func `else`<V: View>(_ view: V) -> some View {
        self ?? view
    }
    
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

// MARK: - Helpers -

extension Optional {
    public func ifSome<Content: View>(@ViewBuilder content: (Wrapped) -> Content) -> UnwrapOptionalView<Wrapped, Content> {
        .init(self, content: content)
    }
}

extension View {
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
