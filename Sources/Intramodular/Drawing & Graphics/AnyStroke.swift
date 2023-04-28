//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct AnyStroke {
    public let content: AnyShapeStyle
    public let style: StrokeStyle
    
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
    public func stroke(_ stroke: AnyStroke) -> some View {
        self.stroke(stroke.content, style: stroke.style)
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
}
