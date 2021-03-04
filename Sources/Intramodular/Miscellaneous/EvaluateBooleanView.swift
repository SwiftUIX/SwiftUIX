//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct EvaluateBooleanView<Content: View>: View {
    @usableFromInline
    let content: Content?
    
    @inlinable
    public init(_ value: Bool, @ViewBuilder content: () -> Content) {
        self.content = value ? content() : nil
    }
    
    @inlinable
    public var body: some View {
        content ?? EmptyView()
    }
    
    @inlinable
    public func `else`<V: View>(@ViewBuilder _ view: () -> V) -> some View {
        self ?? view()
    }
    
    @inlinable
    public func `else`<V: View>(_ view: V) -> some View {
        self ?? view
    }
    
    @inlinable
    public static func ?? <V: View>(lhs: Self, rhs: V) -> some View {
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

extension Bool {
    @inlinable
    public func ifTrue<Content: View>(@ViewBuilder content: () -> Content) -> EvaluateBooleanView<Content> {
        .init(self, content: content)
    }
    
    @inlinable
    public func ifFalse<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        Group {
            if self {
                EmptyView()
            } else {
                content()
            }
        }
    }
}
