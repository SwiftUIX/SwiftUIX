//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct PartlyRoundedRectangle: Shape {
    public let corners: [RectangleCorner]
    public let cornerRadii: CGFloat
    
    public init(corners: [RectangleCorner], cornerRadii: CGFloat) {
        self.corners = corners
        self.cornerRadii = cornerRadii
    }
    
    public func path(in rect: CGRect) -> Path {
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        return Path(
            UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: .init(corners),
                cornerRadii: .init(width: cornerRadii, height: cornerRadii)
            )
        )
        #elseif os(macOS)
        return Path(NSBezierPath(rect: rect, byRoundingCorners: corners, cornerRadii: cornerRadii).cgPath)
        #endif
    }
}

// MARK: - API -

extension View {
    @inlinable
    public func cornerRadius(
        _ corners: [RectangleCorner],
        _ cornerRadii: CGFloat
    ) -> some View {
        clipShape(PartlyRoundedRectangle(corners: corners, cornerRadii: cornerRadii))
    }
}
