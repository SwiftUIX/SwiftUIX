//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct UnwrapOptionalView<Content: View>: View {
    private let content: Content?
    
    public init<Value>(_ value: Optional<Value>, @ViewBuilder content: (Value) -> Content) {
        self.content = value.map(content)
    }
    
    @inline(never)
    public var body: some View {
        content ?? EmptyView()
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

extension UnwrapOptionalView {
    @inline(never)
    public func `else`<V: View>(@ViewBuilder _ view: () -> V) -> some View {
        (self ?? view()).eraseToAnyView()
    }
    
    @inline(never)
    public func `else`<V: View>(_ view: V) -> some View {
        (self ?? view).eraseToAnyView()
    }
}

// MARK: - Helpers -

extension Optional {
    public func ifSome<Content: View>(@ViewBuilder content: (Wrapped) -> Content) -> UnwrapOptionalView<Content> {
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
