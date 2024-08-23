//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@_documentation(visibility: internal)
public struct Square: InsettableShape {
    public typealias InsetShape = Square
    
    fileprivate let insetAmount: Double
    
    public init(insetAmount: Double) {
        self.insetAmount = insetAmount
    }
    
    public init() {
        self.init(insetAmount: 0)
    }
    
    public func path(in rect: CGRect) -> Path {
        Path { path in
            let rect = rect.insetBy(
                dx: insetAmount,
                dy: insetAmount
            )
            
            let isHeightMajor = rect.width < rect.height
            let squareLength = min(rect.width, rect.height)
            
            let x = isHeightMajor ? 0 : (rect.width - squareLength) / 2
            let y = isHeightMajor ? (rect.height - squareLength) / 2 : 0
            
            path.addRect(
                CGRect(x: x, y: y, width: squareLength, height: squareLength).offsetBy(dx: rect.minX, dy: rect.minY)
            )
        }
    }
    
    public func inset(by amount: CGFloat) -> InsetShape {
        .init(insetAmount: insetAmount + amount)
    }
}
