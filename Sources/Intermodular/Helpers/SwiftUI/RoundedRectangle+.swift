//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension View {
    /// Clips this view to its bounding frame, with the specific corner radius.
    public func cornerRadius(_ radius: CGFloat, style: RoundedCornerStyle) -> some View {
        clipShape(RoundedRectangle(cornerRadius: radius, style: style))
    }
    
    /// Adds a rounded border to this view.
    public func border<S: ShapeStyle>(
        _ content: S,
        width lineWidth: CGFloat = 1,
        cornerRadius: CGFloat,
        antialiased: Bool
    ) -> some View {
        self.cornerRadius(cornerRadius, antialiased: antialiased)
            .overlay(
                LineWidthInsetRoundedRectangle(
                    cornerRadius: cornerRadius,
                    style: .circular,
                    lineWidth: lineWidth
                )
                .stroke(content, lineWidth: lineWidth)
            )
    }
    
    /// Adds a rounded border to this view with the specified width and rounded corner style.
    public func border<S: ShapeStyle>(
        _ content: S,
        width lineWidth: CGFloat = 1,
        cornerRadius: CGFloat,
        style: RoundedCornerStyle = .circular
    ) -> some View {
        clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: style))
            .overlay(
                LineWidthInsetRoundedRectangle(
                    cornerRadius: cornerRadius,
                    style: style,
                    lineWidth: lineWidth
                )
                .stroke(content, lineWidth: lineWidth)
            )
    }
}

private struct LineWidthInsetRoundedRectangle: Shape {
    let cornerRadius: CGFloat
    let style: RoundedCornerStyle
    let lineWidth: CGFloat
    
    init(
        cornerRadius: CGFloat,
        style: RoundedCornerStyle = .circular,
        lineWidth: CGFloat
    ) {
        self.cornerRadius = cornerRadius
        self.style = style
        self.lineWidth = lineWidth
    }
    
    func path(in rect: CGRect) -> Path {
        let ratio = (cornerRadius / rect.minimumDimensionLength)
        let newCornerRadius = ratio * (rect.minimumDimensionLength + (lineWidth * 2))
        
        return RoundedRectangle(cornerRadius: newCornerRadius, style: style)
            .path(in: rect)
    }
}
