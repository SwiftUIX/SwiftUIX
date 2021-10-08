//
// Copyright (c) Vatsal Manot
//

import SwiftUI

public struct RoundedHexagon: Shape {
    struct Segment: CaseIterable {
        static let allCases: [Segment] = [
            .init(xFactors: (0.6, 0.4, 0.5), yFactors: (0.05, 0.05, 0.0)),
            .init(xFactors: (0.08, 0.0, 0.0), yFactors: (0.2, 0.35, 0.25)),
            .init(xFactors: (0.0, 0.08, 0.0), yFactors: (0.65, 0.8, 0.75)),
            .init(xFactors: (0.4, 0.6, 0.5), yFactors: (0.95, 0.95, 1.0)),
            .init(xFactors: (0.92, 1.0, 1.0), yFactors: (0.8, 0.65, 0.75)),
            .init(xFactors: (1.0, 0.92, 1.0), yFactors: (0.35, 0.2, 0.25))
        ]

        let xFactors: (CGFloat, CGFloat, CGFloat)
        let yFactors: (CGFloat, CGFloat, CGFloat)
    }
    
    public init() {
        
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        path.move(
            to: CGPoint(
                x: width * Segment.allCases[0].xFactors.0,
                y: height * Segment.allCases[0].yFactors.0
            )
        )
        
        Segment.allCases.forEach {
            path.addLine(
                to: CGPoint(
                    x: width * $0.xFactors.0,
                    y: height * $0.yFactors.0
                )
            )
            
            path.addQuadCurve(
                to: CGPoint(
                    x: width * $0.xFactors.1,
                    y: height * $0.yFactors.1
                ),
                
                control: CGPoint(
                    x: width * $0.xFactors.2,
                    y: height * $0.yFactors.2
                )
            )
        }
        
        return path
    }
}
