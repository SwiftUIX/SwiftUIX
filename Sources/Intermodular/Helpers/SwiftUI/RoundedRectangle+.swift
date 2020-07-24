//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension View {
    @inlinable
    public func cornerRadius(_ radius: CGFloat, style: RoundedCornerStyle) -> some View {
        clipShape(RoundedRectangle(cornerRadius: radius, style: style))
    }
    
    @inlinable
    public func border<S: ShapeStyle>(
        _ content: S,
        cornerRadius: CGFloat,
        style: RoundedCornerStyle = .circular,
        width: CGFloat = 1
    ) -> some View {
        clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: style))
            .overlay(
                LineWidthInsetRoundedRectangle(
                    cornerRadius: cornerRadius,
                    style: style,
                    lineWidth: width
                )
                .stroke(content, lineWidth: width)
            )
            .padding(width / 2)
    }
}

@usableFromInline
struct LineWidthInsetRoundedRectangle: Shape {
    @usableFromInline
    let cornerRadius: CGFloat
    @usableFromInline
    let style: RoundedCornerStyle
    @usableFromInline
    let lineWidth: CGFloat
    
    @usableFromInline
    init(
        cornerRadius: CGFloat,
        style: RoundedCornerStyle = .circular,
        lineWidth: CGFloat
    ) {
        self.cornerRadius = cornerRadius
        self.style = style
        self.lineWidth = lineWidth
    }
    
    @usableFromInline
    func path(in rect: CGRect) -> Path {
        let ratio = (cornerRadius / rect.minimumDimensionLength)
        let newCornerRadius = ratio * (rect.minimumDimensionLength + (lineWidth * 2))
        
        return RoundedRectangle(cornerRadius: newCornerRadius, style: style)
            .path(in: rect)
    }
}
