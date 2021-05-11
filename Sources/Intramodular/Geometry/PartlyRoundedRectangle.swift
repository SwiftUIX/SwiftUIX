//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct PartRoundedRectangle: Shape {
    public let corners: [RectangleCorner]
    public let cornerRadii: CGFloat
    
    public init(corners: [RectangleCorner], cornerRadii: CGFloat) {
        self.corners = corners
        self.cornerRadii = cornerRadii
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
    
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    @_disfavoredOverload
    public func cornerRadius(_ corners: UIRectCorner, _ cornerRadii: CGFloat) -> some View {
        clipShape(PartRoundedRectangle(corners: .init(corners), cornerRadii: cornerRadii))
    }
    #endif
}

#endif
