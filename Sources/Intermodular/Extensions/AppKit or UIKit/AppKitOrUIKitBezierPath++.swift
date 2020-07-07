//
// Copyright (c) Vatsal Manot
//

#if canImport(AppKit) || canImport(UIKit)

import SwiftUI

extension AppKitOrUIKitBezierPath {
    #if os(iOS) || os(tvOS)
    public func curve(to point: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint) {
        addCurve(to: point, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
    }
    
    public func line(to point: CGPoint) {
        addLine(to: point)
    }
    #endif
    
    public convenience init(
        rect: CGRect,
        byRoundingCorners corners: [RectangleCorner],
        cornerRadii: CGFloat
    ) {
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
        
        self.close()
    }
}

#endif
