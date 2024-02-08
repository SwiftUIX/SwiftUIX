//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public enum _SwiftUIX_AxisStackLayoutDirection {
    case forward
    case reverse
}

/// A view that arranges its children in a vertical/horizontal line.
@frozen
public struct AxisStack<Content: View>: View {
    public let axis: Axis3D
    public let alignment: Alignment
    public let spacing: CGFloat?
    public let content: Content
    
    public var body: some View {
        if axis == .x {
            HStack(
                alignment: self.alignment.vertical,
                spacing: self.spacing,
                content: { content }
            )
        } else if axis == .y {
            VStack(
                alignment: self.alignment.horizontal,
                spacing: self.spacing,
                content: { content }
            )
        } else if axis == .z {
            ZStack(
                alignment: self.alignment,
                content: { content }
            )
        }
    }
}

extension AxisStack {
    public init(
        axis: Axis3D,
        alignment: Alignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.axis = axis
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }
    
    public init(
        axis: Axis,
        alignment: Alignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.axis = .init(axis)
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }
}
