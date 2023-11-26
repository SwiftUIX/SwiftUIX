//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension VStack {
    public enum _ProportionalFill {
        case proportionally
    }
    
    @_disfavoredOverload
    @inlinable
    public init(
        alignment: HorizontalAlignment = .center,
        fill: _ProportionalFill,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.init(alignment: alignment, spacing: spacing, content: content)
    }
    
    @inlinable
    public init<V0: View, V1: View>(
        alignment: HorizontalAlignment = .center,
        fill: _ProportionalFill,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> TupleView<(V0, V1)>
    ) where Content == AnyView {
        let content = content()
        
        self.init {
            GeometryReader { geometry in
                SwiftUI.VStack(alignment: alignment, spacing: spacing) {
                    content.value.0.frame(height: geometry.size.height / 2.0)
                    content.value.1.frame(height: geometry.size.height / 2.0)
                }
            }
            .eraseToAnyView()
        }
    }
    
    @inlinable
    public init<V0: View, V1: View, V2: View>(
        alignment: HorizontalAlignment = .center,
        fill: _ProportionalFill,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> TupleView<(V0, V1, V2)>
    ) where Content == AnyView {
        let content = content()
        
        self.init {
            GeometryReader { geometry in
                SwiftUI.VStack(alignment: alignment, spacing: spacing) {
                    content.value.0.frame(height: geometry.size.height / 3.0)
                    content.value.1.frame(height: geometry.size.height / 3.0)
                    content.value.2.frame(height: geometry.size.height / 3.0)
                }
            }
            .eraseToAnyView()
        }
    }
    
    @inlinable
    public init<V0: View, V1: View, V2: View, V3: View>(
        alignment: HorizontalAlignment = .center,
        fill: _ProportionalFill,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> TupleView<(V0, V1, V2, V3)>
    ) where Content == AnyView {
        let content = content()
        
        self.init {
            GeometryReader { geometry in
                SwiftUI.VStack(alignment: alignment, spacing: spacing) {
                    content.value.0.frame(height: geometry.size.height / 4.0)
                    content.value.1.frame(height: geometry.size.height / 4.0)
                    content.value.2.frame(height: geometry.size.height / 4.0)
                    content.value.3.frame(height: geometry.size.height / 4.0)
                }
            }
            .eraseToAnyView()
        }
    }
}
