//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A view that arranges its children in a vertical/horizontal line.
public struct AxisStack<Content: View>: View {
    public let axis: Axis
    public let alignment: Alignment
    public let spacing: CGFloat?
    public let content: Content
    
    @inlinable
    public init(
        axis: Axis,
        alignment: Alignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.axis = axis
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }
    
    public var body: some View {
        Group {
            if axis == .horizontal {
                HStack(
                    alignment: self.alignment.vertical,
                    spacing: self.spacing,
                    content: { content }
                )
            } else {
                VStack(
                    alignment: self.alignment.horizontal,
                    spacing: self.spacing,
                    content: { content }
                )
            }
        }
    }
}
