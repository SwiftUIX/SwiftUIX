//
// Copyright (c) Vatsal Manot
//

import SwiftUI

extension View {
    /// Causes the view to fill into its superview.
    public func _fill(alignment: Alignment = .center) -> some View {
        GeometryReader { geometry in
            return self.frame(
                width: geometry.size.width,
                height: geometry.size.height,
                alignment: alignment
            )
        }
    }

    public func eraseToAnyView() -> AnyView {
        return .init(self)
    }
}
