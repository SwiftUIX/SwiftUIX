//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct PartRoundedRectangle {
    public let corners: [RectangleCorner]
    public let cornerRadii: CGFloat
    
    public init(corners: [RectangleCorner], cornerRadii: CGFloat) {
        self.corners = corners
        self.cornerRadii = cornerRadii
    }
}

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)
extension PartRoundedRectangle: Shape {
    public func path(in rect: CGRect) -> Path {
        Path(
            AppKitOrUIKitBezierPath(
                roundedRect: rect,
                byRoundingCorners: corners,
                cornerRadii: cornerRadii
            )
            ._cgPath
        )
    }
}
#endif

// MARK: - API

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)
extension View {
    @inlinable
    public func cornerRadius(
        _ corners: [RectangleCorner],
        _ cornerRadii: CGFloat
    ) -> some View {
        clipShape(PartRoundedRectangle(corners: corners, cornerRadii: cornerRadii))
    }
    
    @inlinable
    public func cornerRadius(
        _ corners: Set<RectangleCorner>,
        _ cornerRadii: CGFloat
    ) -> some View {
        clipShape(PartRoundedRectangle(corners: Array(corners), cornerRadii: cornerRadii))
    }
    
    @inlinable
    public func cornerRadius(
        _ corner: RectangleCorner,
        _ cornerRadii: CGFloat
    ) -> some View {
        clipShape(PartRoundedRectangle(corners: [corner], cornerRadii: cornerRadii))
    }
    
    @_disfavoredOverload
    public func cornerRadius(_ corners: AppKitOrUIKitRectCorner, _ cornerRadii: CGFloat) -> some View {
        clipShape(PartRoundedRectangle(corners: .init(corners), cornerRadii: cornerRadii))
    }
}
#endif
