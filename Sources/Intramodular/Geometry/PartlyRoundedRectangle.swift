//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct PartRoundedRectangle: Shape {
    public let corners: UIRectCorner
    public let cornerRadii: CGFloat

    public init(corners: UIRectCorner, cornerRadii: CGFloat) {
        self.corners = corners
        self.cornerRadii = cornerRadii
    }

    public init(corners: [RectangleCorner], cornerRadii: CGFloat) {
        self.init(corners: .init(corners), cornerRadii: cornerRadii)
    }

    public func path(in rect: CGRect) -> Path {
        return Path(
            AppKitOrUIKitBezierPath(
                roundedRect: rect,
                byRoundingCorners: corners,
                cornerRadii: cornerRadii
            )
            .cgPath
        )
    }
}

// MARK: - API -

extension View {
    @inlinable
    public func cornerRadius(
        _ corners: [RectangleCorner],
        _ cornerRadii: CGFloat
    ) -> some View {
        clipShape(PartRoundedRectangle(corners: corners, cornerRadii: cornerRadii))
    }

    @_disfavoredOverload
    public func cornerRadius(_ corners: UIRectCorner, _ cornerRadii: CGFloat) -> some View {
        clipShape(PartRoundedRectangle(corners: corners, cornerRadii: cornerRadii))
    }
}

#endif
