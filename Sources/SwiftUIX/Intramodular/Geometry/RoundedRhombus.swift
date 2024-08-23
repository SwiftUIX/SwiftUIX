//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

@_documentation(visibility: internal)
public struct RoundedRhombus: Shape {
    public let cornerRadius: CGFloat
    
    public init(cornerRadius: CGFloat) {
        self.cornerRadius = cornerRadius
    }
    
    public func path(in rect: CGRect) -> Path {
        let result = AppKitOrUIKitBezierPath()
        
        let points = [
            CGPoint(x: rect.midX, y: rect.minY),
            CGPoint(x: rect.maxX, y: rect.midY),
            CGPoint(x: rect.midX, y: rect.maxY),
            CGPoint(x: rect.minX, y: rect.midY)
        ]
        
        result.move(
            to: point(
                from: points[0],
                to: points[1],
                distance: cornerRadius,
                fromStart: true
            )
        )
        
        for index in 0..<4 {
            result.addLine(
                to: point(
                    from: points[index],
                    to: points[(index + 1) % 4],
                    distance: cornerRadius,
                    fromStart: false
                )
            )
            
            result.addQuadCurve(
                to: point(
                    from: points[(index + 1) % 4],
                    to: points[(index + 2) % 4],
                    distance: cornerRadius,
                    fromStart: true
                ),
                controlPoint: points[(index + 1) % 4]
            )
        }
        
        result.close()

        return .init(result)
    }
    
    private func point(
        from point1: CGPoint,
        to point2: CGPoint,
        distance: CGFloat,
        fromStart: Bool
    ) -> CGPoint {
        let start: CGPoint
        let end: CGPoint
        
        if fromStart {
            start = point1
            end = point2
        } else {
            start = point2
            end = point1
        }
        
        let angle = atan2(end.y - start.y, end.x - start.x)
        
        return CGPoint(
            x: start.x + distance * cos(angle),
            y: start.y + distance * sin(angle)
        )
    }
}

#endif
