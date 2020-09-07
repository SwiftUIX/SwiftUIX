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
            .padding(lineWidth / 2)
    }
    
    @inlinable
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
            .padding(lineWidth / 2)
    }
}

extension View {
    @available(*, deprecated, message: "Please use View.border(_:width:cornerRadius:antialiased:) instead.")
    @inlinable
    public func border<S: ShapeStyle>(
        _ content: S,
        cornerRadius: CGFloat,
        width lineWidth: CGFloat,
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
            .padding(lineWidth / 2)
    }
    
    @available(*, deprecated, message: "Please use View.border(_:width:cornerRadius:style:) instead.")
    @inlinable
    public func border<S: ShapeStyle>(
        _ content: S,
        cornerRadius: CGFloat,
        width lineWidth: CGFloat,
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
            .padding(lineWidth / 2)
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
