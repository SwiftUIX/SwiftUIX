//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension HStack {
    public enum _ProportionalFill {
        case proportionally
    }
    
    @_disfavoredOverload
    @inlinable
    public init(
        alignment: VerticalAlignment = .center,
        fill: _ProportionalFill,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.init(alignment: alignment, spacing: spacing, content: content)
    }
    
    @inlinable
    public init<V0: View, V1: View>(
        alignment: VerticalAlignment = .center,
        fill: _ProportionalFill,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> TupleView<(V0, V1)>
    ) where Content == AnyView {
        let content = content()
        
        self.init {
            GeometryReader { geometry in
                SwiftUI.HStack(alignment: alignment, spacing: spacing) {
                    content.value.0.frame(width: geometry.size.width / 2)
                    content.value.1.frame(width: geometry.size.width / 2)
                }
            }
            .eraseToAnyView()
        }
    }
    
    @inlinable
    public init<V0: View, V1: View, V2: View>(
        alignment: VerticalAlignment = .center,
        fill: _ProportionalFill,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> TupleView<(V0, V1, V2)>
    ) where Content == AnyView {
        let content = content()
        
        self.init {
            GeometryReader { geometry in
                SwiftUI.HStack(alignment: alignment, spacing: spacing) {
                    content.value.0.frame(width: geometry.size.width / 3)
                    content.value.1.frame(width: geometry.size.width / 3)
                    content.value.2.frame(width: geometry.size.width / 3)
                }
            }
            .eraseToAnyView()
        }
    }
    
    @inlinable
    public init<V0: View, V1: View, V2: View, V3: View>(
        alignment: VerticalAlignment = .center,
        fill: _ProportionalFill,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> TupleView<(V0, V1, V2, V3)>
    ) where Content == AnyView {
        let content = content()
        
        self.init {
            GeometryReader { geometry in
                SwiftUI.HStack(alignment: alignment, spacing: spacing) {
                    content.value.0.frame(width: geometry.size.width / 4)
                    content.value.1.frame(width: geometry.size.width / 4)
                    content.value.2.frame(width: geometry.size.width / 4)
                    content.value.3.frame(width: geometry.size.width / 4)
                }
            }
            .eraseToAnyView()
        }
    }
}

extension HStack {
    @_disfavoredOverload
    @inlinable
    public init<V: View>(
        direction: LayoutDirection,
        alignment: VerticalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> V
    ) where Content == AnyView {
        let content = content()
        
        self = HStack(alignment: alignment, spacing: spacing) {
            content.eraseToAnyView()
        }
    }
    
    @inlinable
    public init<V0: View, V1: View>(
        direction: LayoutDirection,
        alignment: VerticalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> TupleView<(V0, V1)>
    ) where Content == AnyView {
        let content = content()
        
        self = HStack {
            if direction == .leftToRight {
                return HStack<TupleView<(V0, V1)>>(alignment: alignment, spacing: spacing) {
                    content.value.0
                    content.value.1
                }
                .eraseToAnyView()
            } else {
                return HStack<TupleView<(V1, V0)>>(alignment: alignment, spacing: spacing) {
                    content.value.1
                    content.value.0
                }
                .eraseToAnyView()
            }
        }
    }
    
    @inlinable
    public init<V0: View, V1: View, V2: View>(
        direction: LayoutDirection,
        alignment: VerticalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> TupleView<(V0, V1, V2)>
    ) where Content == AnyView {
        let content = content()
        
        self = HStack {
            if direction == .leftToRight {
                return HStack<TupleView<(V0, V1, V2)>>(alignment: alignment, spacing: spacing) {
                    content.value.0
                    content.value.1
                    content.value.2
                }
                .eraseToAnyView()
            } else {
                return HStack<TupleView<(V2, V1, V0)>>(alignment: alignment, spacing: spacing) {
                    content.value.2
                    content.value.1
                    content.value.0
                }
                .eraseToAnyView()
            }
        }
    }
    
    @inlinable
    public init<V0: View, V1: View, V2: View, V3: View>(
        direction: LayoutDirection,
        alignment: VerticalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> TupleView<(V0, V1, V2, V3)>
    ) where Content == AnyView {
        let content = content()
        
        self = HStack {
            if direction == .leftToRight {
                return HStack<TupleView<(V0, V1, V2, V3)>>(alignment: alignment, spacing: spacing) {
                    content.value.0
                    content.value.1
                    content.value.2
                    content.value.3
                }
                .eraseToAnyView()
            } else {
                return HStack<TupleView<(V3, V2, V1, V0)>>(alignment: alignment, spacing: spacing) {
                    content.value.3
                    content.value.2
                    content.value.1
                    content.value.0
                }
                .eraseToAnyView()
            }
        }
    }
}
