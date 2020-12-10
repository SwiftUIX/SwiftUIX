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
