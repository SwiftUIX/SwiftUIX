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

    public func _relativeHeight(_ ratio: Length, alignment: Alignment = .center) -> some View {
        GeometryReader { geometry in
            self.frame(
                height: geometry.size.height * ratio,
                alignment: alignment
            )
        }
    }

    public func _relativeWidth(_ ratio: Length, alignment: Alignment = .center) -> some View {
        GeometryReader { geometry in
            self.frame(
                width: geometry.size.width * ratio,
                alignment: alignment
            )
        }
    }

    public func _relativeSize(_ widthRatio: Length, _ heightRatio: Length, alignment: Alignment = .center) -> some View {
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
