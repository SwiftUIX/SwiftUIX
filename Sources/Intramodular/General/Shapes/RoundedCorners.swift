//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if canImport(UIKit)

public struct RoundedCorners: Shape {
    public let radius: CGFloat
    public let corners: UIRectCorner
    
    public init(radius: CGFloat, corners: UIRectCorner) {
        self.radius = radius
        self.corners = corners
    }
    
    public func path(in rect: CGRect) -> Path {
        Path(
            UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)
            )
        )
    }
}

#endif

// MARK: - API -

#if canImport(UIKit)

extension View {
    @inlinable
    public func cornerRadius(_ corners: UIRectCorner, _ radius: CGFloat) -> some View {
        clipShape(RoundedCorners(radius: radius, corners: corners))
    }
}

#endif
