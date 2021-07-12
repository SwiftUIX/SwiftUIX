//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension Shape {
    public func fill<S: ShapeStyle>(
        _ fillContent: S,
        stroke strokeStyle: StrokeStyle
    ) -> some View {
        ZStack {
            fill(fillContent)
            stroke(style: strokeStyle)
        }
    }
    
    public func fillAndStrokeBorder<S: ShapeStyle>(
        _ fillContent: S,
        borderColor: Color,
        borderWidth: CGFloat,
        antialiased: Bool = true
    ) -> some View where Self: InsettableShape {
        ZStack {
            inset(by: borderWidth / 2).fill(fillContent)
            
            self.strokeBorder(
                borderColor,
                lineWidth: borderWidth,
                antialiased: antialiased
            )
        }
        .compositingGroup()
    }
}
