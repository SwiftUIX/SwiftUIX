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
        
        #if os(iOS) || os(tvOS)
        let corners = corners.map({ $0.flip() })
        #elseif os(macOS)
        let corners = corners
        #endif
        
        let maxX: CGFloat = rect.size.width
        let minX: CGFloat = 0
        let maxY: CGFloat = rect.size.height
        let minY: CGFloat =  0
        
        let bottomRightCorner = CGPoint(x: maxX, y: minY)
        
        move(to: bottomRightCorner)
        
        if corners.contains(.bottomTrailing) {
            line(to: CGPoint(x: maxX - cornerRadii, y: minY))
            curve(to: CGPoint(x: maxX, y: minY + cornerRadii), controlPoint1: bottomRightCorner, controlPoint2: bottomRightCorner)
        } else {
            line(to: bottomRightCorner)
        }
        
        let topRightCorner = CGPoint(x: maxX, y: maxY)
        
        if corners.contains(.topTrailing) {
            line(to: CGPoint(x: maxX, y: maxY - cornerRadii))
            curve(to: CGPoint(x: maxX - cornerRadii, y: maxY), controlPoint1: topRightCorner, controlPoint2: topRightCorner)
        } else {
            line(to: topRightCorner)
        }
        
        let topLeftCorner = CGPoint(x: minX, y: maxY)
        
        if corners.contains(.topLeading) {
            line(to: CGPoint(x: minX + cornerRadii, y: maxY))
            curve(to: CGPoint(x: minX, y: maxY - cornerRadii), controlPoint1: topLeftCorner, controlPoint2: topLeftCorner)
        } else {
            line(to: topLeftCorner)
        }
        
        let bottomLeftCorner = CGPoint(x: minX, y: minY)
        
        if corners.contains(.bottomLeading) {
            line(to: CGPoint(x: minX, y: minY + cornerRadii))
            curve(to: CGPoint(x: minX + cornerRadii, y: minY), controlPoint1: bottomLeftCorner, controlPoint2: bottomLeftCorner)
        } else {
            line(to: bottomLeftCorner)
        }
    }
}

#endif
