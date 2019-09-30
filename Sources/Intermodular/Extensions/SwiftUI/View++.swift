//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

// MARK: - General -

extension View {
    /// Returns a type-erased version of `self`.
    @inlinable
    public func eraseToAnyView() -> AnyView {
        return .init(self)
    }
}

// MARK: - Positioning -

extension View {
    public func inset(by point: CGPoint) -> some View {
        return offset(x: -point.x, y: -point.y)
    }

    public func offset(by point: CGPoint) -> some View {
        return offset(x: point.x, y: point.y)
    }
}

// MARK: - Relative Sizing -

extension View {
    public func relativeHeight(
        _ ratio: CGFloat,
        alignment: Alignment = .center
    ) -> some View {
        GeometryReader { geometry in
            self.frame(
                height: geometry.size.height * ratio,
                alignment: alignment
            )
        }
    }
    
    public func relativeWidth(
        _ ratio: CGFloat,
        alignment: Alignment = .center
    ) -> some View {
        GeometryReader { geometry in
            self.frame(
                width: geometry.size.width * ratio,
                alignment: alignment
            )
        }
    }
    
    public func relativeSize(
        width widthRatio: CGFloat,
        height heightRatio: CGFloat,
        alignment: Alignment = .center
    ) -> some View {
        GeometryReader { geometry in
            self.frame(
                width: geometry.size.width * widthRatio,
                height: geometry.size.height * heightRatio,
                alignment: alignment
            )
        }
    }
    
    /// Causes the view to fill into its superview.
    public func fill(alignment: Alignment = .center) -> some View {
        relativeSize(width: 1.0, height: 1.0)
    }
}

// MARK: - Debugging -

extension View {
    public func debugBorderRed() -> some View {
        return border(Color.red, width: 2)
    }

    public func debugBorderGreen() -> some View {
        return border(Color.green, width: 2)
    }
}

// MARK: - Compatibility -

#if os(macOS)

extension View {
    @available(*, deprecated, message: "This function is currently unavailable on macOS.")
    public func navigationBarTitle(_ title: String) -> some View {
        return self
    }
    
    @available(*, deprecated, message: "This function is currently unavailable on macOS.")
    public func navigationBarItems<V: View>(trailing: V) -> some View {
        return self
    }
}

#endif
