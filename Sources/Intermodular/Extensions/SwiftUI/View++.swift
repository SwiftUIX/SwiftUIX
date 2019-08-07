//
// Copyright (c) Vatsal Manot
//

import SwiftUI

// MARK: Relative Sizing

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
}

extension View {
    public func relativeHeight(_ ratio: CGFloat, alignment: Alignment = .center) -> some View {
        GeometryReader { geometry in
            self.frame(
                height: geometry.size.height * ratio,
                alignment: alignment
            )
        }
    }

    public func relativeWidth(_ ratio: CGFloat, alignment: Alignment = .center) -> some View {
        GeometryReader { geometry in
            self.frame(
                width: geometry.size.width * ratio,
                alignment: alignment
            )
        }
    }

    public func relativeSize(_ widthRatio: CGFloat, _ heightRatio: CGFloat, alignment: Alignment = .center) -> some View {
        GeometryReader { geometry in
            self.frame(
                width: geometry.size.width * widthRatio,
                height: geometry.size.height * heightRatio,
                alignment: alignment
            )
        }
    }
}

// MARK: General

extension View {
    /// Returns a type-erased version of `self`.
    @inlinable
    public func eraseToAnyView() -> AnyView {
        return .init(self)
    }
}
