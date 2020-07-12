//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

import SwiftUI

extension AppKitOrUIKitBezierPath {
    public convenience init(
        roundedRect rect: CGRect,
        byRoundingCorners corners: [RectangleCorner],
        cornerRadii: CGFloat
    ) {
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        self.init(
            roundedRect: rect,
            byRoundingCorners: .init(corners),
            cornerRadii: .init(width: cornerRadii, height: cornerRadii)
        )
        #elseif os(macOS)
        self.init()
        
        let topLeft = NSPoint(x: rect.minX, y: rect.minY)
        let topRight = NSPoint(x: rect.maxX, y: rect.minY)
        let bottomRight = NSPoint(x: rect.maxX, y: rect.maxY)
        let bottomLeft = NSPoint(x: rect.minX, y: rect.maxY)
        
        move(to: CGPoint(x: topLeft.x, y: topLeft.y + cornerRadii))
        
        appendArc(from: topLeft, to: topRight, radius: corners.contains(.topLeading) ? cornerRadii : 0)
        appendArc(from: topRight, to: bottomRight, radius: corners.contains(.topTrailing) ? cornerRadii : 0)
        appendArc(from: bottomRight, to: bottomLeft, radius: corners.contains(.bottomTrailing) ? cornerRadii : 0)
        appendArc(from: bottomLeft, to: topLeft, radius: corners.contains(.bottomLeading) ? cornerRadii : 0)
        
        close()
        #endif
    }
}

#endif
