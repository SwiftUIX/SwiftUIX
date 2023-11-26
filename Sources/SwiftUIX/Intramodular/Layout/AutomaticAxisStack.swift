//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A view that arranges its children in a vertical/horizontal line.
///
/// The axis is determined in accordance to the size proposed by the parent container.
public struct AutomaticAxisStack<Content: View>: View {
    public let preferredAxis: Axis
    public let alignment: Alignment
    public let spacing: CGFloat?
    public let content: Content
    
    @usableFromInline
    @State var intrinsicGeometrySize: CGSize = .zero
    
    @usableFromInline
    @State var geometrySize: CGSize = .zero
    
    @usableFromInline
    @State var wantsRealign: Bool = false
    
    public init(
        preferredAxis: Axis,
        alignment: Alignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.preferredAxis = preferredAxis
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }
    
    @inlinable
    public var body: some View {
        PassthroughView {
            if wantsRealign {
                AxisStack(
                    axis: self.preferredAxis.orthogonal,
                    alignment: self.alignment,
                    spacing: self.spacing
                ) {
                    self.content
                }
            } else {
                GeometryReader { geometry in
                    AxisStack(
                        axis: self.preferredAxis,
                        alignment: self.alignment,
                        spacing: self.spacing
                    ) {
                        self.content
                    }
                    .fixedSize()
                    .background(GeometryReader { intrinsicGeometry in
                        ZeroSizeView().then { _ in
                            DispatchQueue.main.async {
                                if intrinsicGeometry.size.dimensionLength(for: self.preferredAxis) > geometry.size.dimensionLength(for: self.preferredAxis) {
                                    self.intrinsicGeometrySize = intrinsicGeometry.size
                                    self.geometrySize = geometry.size
                                    self.wantsRealign = true
                                }
                            }
                        }
                    })
                }
                .frame(
                    min: intrinsicGeometrySize.dimensionLength(for: preferredAxis),
                    axis: preferredAxis
                )
            }
        }
    }
}

/// A view that arranges its children in a vertical/horizontal line.
///
/// The axis is determined in accordance to the size proposed by the parent container.
/// The preferred line is horizontal.
public struct HVStack<Content: View>: View {
    public let alignment: Alignment
    public let spacing: CGFloat?
    public let content: Content
    
    public init(
        alignment: Alignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }
    
    @inlinable
    public var body: some View {
        AutomaticAxisStack(
            preferredAxis: .horizontal,
            alignment: alignment,
            spacing: spacing,
            content: { content }
        )
    }
}

/// A view that arranges its children in a vertical/horizontal line.
///
/// The axis is determined in accordance to the size proposed by the parent container.
/// The preferred line is vertical.
public struct VHStack<Content: View>: View {
    public let alignment: Alignment
    public let spacing: CGFloat?
    public let content: Content
    
    public init(
        alignment: Alignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }
    
    @inlinable
    public var body: some View {
        AutomaticAxisStack(
            preferredAxis: .vertical,
            alignment: alignment,
            spacing: spacing,
            content: { content }
        )
    }
}
