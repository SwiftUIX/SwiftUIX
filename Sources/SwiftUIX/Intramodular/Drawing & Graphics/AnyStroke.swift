//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct AnyStroke {
    public let content: AnyShapeStyle?
    public let style: StrokeStyle
    
    public init(style: StrokeStyle) {
        self.content = nil
        self.style = style
    }

    public init<S: ShapeStyle>(_ content: S, style: StrokeStyle) {
        self.content = .init(content)
        self.style = style
    }
    
    public init<S: ShapeStyle>(_ content: S, lineWidth: Double) {
        self.content = .init(content)
        self.style = .init(lineWidth: lineWidth)
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension Shape {
    @ViewBuilder
    public func stroke(_ stroke: AnyStroke) -> some View {
        if let strokeContent = stroke.content {
            self.stroke(strokeContent, style: stroke.style)
        } else {
            self.stroke(style: stroke.style)
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension View {
    public func border<S: InsettableShape>(
        _ shape: S,
        stroke: AnyStroke
    ) -> some View {
        self
            .clipShape(shape)
            .overlay(shape.inset(by: stroke.style.lineWidth / 2).stroke(stroke))
    }
    
    @_disfavoredOverload
    public func border(
        cornerRadius: CGFloat,
        cornerStyle: RoundedCornerStyle = .continuous,
        stroke: AnyStroke
    ) -> some View {
        border(RoundedRectangle(cornerRadius: cornerRadius, style: cornerStyle), stroke: stroke)
    }
    
    @_disfavoredOverload
    public func border(
        cornerRadius: CGFloat,
        style: StrokeStyle
    ) -> some View {
        border(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous),
            stroke: .init(style: style)
        )
    }
    
    @_disfavoredOverload
    public func border<S: ShapeStyle>(
        _ content: S,
        cornerRadius: CGFloat,
        style: StrokeStyle
    ) -> some View {
        border(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous),
            stroke: .init(content, style: style)
        )
    }
}
