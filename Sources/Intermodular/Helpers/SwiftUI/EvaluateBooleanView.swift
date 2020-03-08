//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct EvaluateBooleanView<Content: View>: View {
    private let content: Content?
    
    public init(_ value: Bool, @ViewBuilder content: () -> Content) {
        self.content = value ? content() : nil
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
    public func ifTrue<Content: View>(@ViewBuilder content: () -> Content) -> EvaluateBooleanView<Content> {
        .init(self, content: content)
    }
    
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
