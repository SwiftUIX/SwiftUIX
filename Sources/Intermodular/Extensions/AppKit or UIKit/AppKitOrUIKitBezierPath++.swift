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
        
        let cornerRadius: CGFloat = min(cornerRadii, min(rect.midY, rect.midX))
        let (maxX, minX, maxY, minY, midX, midY) = (rect.size.width, CGFloat(0), rect.size.height, CGFloat(0), rect.midX, rect.midY)

        let topCenter = CGPoint(x: midX, y: minY)
        let topTrailing = CGPoint(x: maxX, y: minY)
        let trailingCenter = CGPoint(x: maxX, y: midY)
        move(to: topCenter)
        if corners.contains(.topTrailing) {
            let x = maxX - cornerRadius
            let y = minY + cornerRadius
            line(to: CGPoint(x: max(x, midX), y: minY))
            appendArc(withCenter: CGPoint(x: x, y: y), radius: cornerRadius, startAngle: 270, endAngle: 0)
            line(to: CGPoint(x: maxX, y: min(y, midY)))
        } else {
            line(to: topTrailing)
            line(to: trailingCenter)
        }

        let bottomTrailing = CGPoint(x: maxX, y: maxY)
        let bottomCenter = CGPoint(x: midX, y: maxY)
        if corners.contains(.bottomTrailing) {
            let x = maxX - cornerRadius
            let y = maxY - cornerRadius
            line(to: CGPoint(x: maxX, y: max(y, midY)))
            appendArc(withCenter: CGPoint(x: x, y: y), radius: cornerRadius, startAngle: 0, endAngle: 90)
            line(to: CGPoint(x: max(x, midX), y: maxY))
        } else {
            line(to: bottomTrailing)
            line(to: bottomCenter)
        }

        let bottomLeading = CGPoint(x: minX, y: maxY)
        let leadingCenter = CGPoint(x: minX, y: midY)
        if corners.contains(.bottomLeading) {
            let x = min(minX + cornerRadius, midX)
            let y = max(maxY - cornerRadius, midY)
            line(to: CGPoint(x: x, y: maxY))
            appendArc(withCenter: CGPoint(x: minX + cornerRadius, y: maxY - cornerRadius), radius: cornerRadius, startAngle: 90, endAngle: 180)
            line(to: CGPoint(x: minX, y: y))
        } else {
            line(to: bottomLeading)
            line(to: leadingCenter)
        }

        let topLeading = CGPoint(x: minX, y: minY)
        if corners.contains(.topLeading) {
            let x = min(minX + cornerRadius, midX)
            let y = min(minY + cornerRadius, midY)
            line(to: CGPoint(x: minX, y: y))
            appendArc(withCenter: CGPoint(x: minX + cornerRadius, y: minY + cornerRadius), radius: cornerRadius, startAngle: 180, endAngle: 270)
            line(to: CGPoint(x: x, y: minY))
        } else {
            line(to: topLeading)
            line(to: topCenter)
        }
        
        close()
        #endif
    }
}

#endif
