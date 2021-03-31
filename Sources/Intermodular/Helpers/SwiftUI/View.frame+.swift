//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension View {
    @inlinable
    public func relativeHeight(
        _ ratio: CGFloat,
        alignment: Alignment = .center
    ) -> some View {
        GeometryReader { geometry in
            self.frame(
                height: geometry.size.height * ratio,
                alignment: alignment
            )
        }
    }
    
    @inlinable
    public func relativeWidth(
        _ ratio: CGFloat,
        alignment: Alignment = .center
    ) -> some View {
        GeometryReader { geometry in
            self.frame(
                width: geometry.size.width * ratio,
                alignment: alignment
            )
        }
    }
    
    @inlinable
    public func relativeSize(
        width widthRatio: CGFloat?,
        height heightRatio: CGFloat?,
        alignment: Alignment = .center
    ) -> some View {
        GeometryReader { geometry in
            self.frame(
                width: widthRatio.map({ $0 * geometry.size.width }),
                height: heightRatio.map({ $0 * geometry.size.height }),
                alignment: alignment
            )
        }
    }
}

extension View {
    /// Causes the view to fill into its container.
    @inlinable
    public func fill(alignment: Alignment = .center) -> some View {
        relativeSize(width: 1.0, height: 1.0, alignment: alignment)
    }
}

public enum _GreedyFrameSize {
    case greedy
}

extension View {
    /// Causes the view to greedily fill into its container.
    @inlinable
    public func frame(
        _ size: _GreedyFrameSize,
        alignment: Alignment = .center
    ) -> some View {
        frame(
            idealWidth: .infinity,
            maxWidth: .infinity,
            idealHeight: .infinity,
            maxHeight: .infinity,
            alignment: alignment
        )
    }
    
    @inlinable
    public func frame(
        width: _GreedyFrameSize,
        alignment: Alignment = .center
    ) -> some View {
        frame(
            idealWidth: .infinity,
            maxWidth: .infinity,
            alignment: alignment
        )
    }
    
    @inlinable
    public func frame(
        width: _GreedyFrameSize,
        height: CGFloat?,
        alignment: Alignment = .center
    ) -> some View {
        frame(
            idealWidth: .infinity,
            maxWidth: .infinity,
            minHeight: height,
            idealHeight: height,
            maxHeight: height,
            alignment: alignment
        )
    }
    
    @inlinable
    public func frame(
        height: _GreedyFrameSize,
        alignment: Alignment = .center
    ) -> some View {
        frame(idealHeight: .infinity, maxHeight: .infinity, alignment: alignment)
    }
    
    @inlinable
    public func frame(
        _ size: _GreedyFrameSize,
        _ axis: Axis,
        alignment: Alignment = .center
    ) -> some View {
        switch axis {
            case .horizontal:
                return frame(idealWidth: .infinity, maxWidth: .infinity, alignment: alignment)
            case .vertical:
                return frame(idealHeight: .infinity, maxHeight: .infinity, alignment: alignment)
        }
    }
    
    @available(*, message: "greedyFrame() is deprecated, use frame(.greedy) instead")
    public func greedyFrame(alignment: Alignment = .center) -> some View {
        frame(.greedy)
    }
}

extension View {
    /// Causes the view to greedily fill to fit into its container.
    @inlinable
    public func fit() -> some View {
        GeometryReader { geometry in
            self.frame(
                width: geometry.size.minimumDimensionLength,
                height: geometry.size.minimumDimensionLength
            )
        }
    }
}

extension View {
    @inlinable
    public func width(_ width: CGFloat?) -> some View {
        frame(width: width)
    }
    
    @inlinable
    public func height(_ height: CGFloat?) -> some View {
        frame(height: height)
    }
    
    /// Positions this view within an invisible frame with the specified size.
    ///
    /// Use this method to specify a fixed size for a view's width,
    /// height, or both. If you only specify one of the dimensions, the
    /// resulting view assumes this view's sizing behavior in the other
    /// dimension.
    @inlinable
    public func frame(_ size: CGSize?, alignment: Alignment = .center) -> some View {
        frame(width: size?.width, height: size?.height, alignment: alignment)
    }
    
    /// Positions this view within an invisible frame with the specified size.
    ///
    /// Use this method to specify a fixed size for a view's width,
    /// height, or both. If you only specify one of the dimensions, the
    /// resulting view assumes this view's sizing behavior in the other
    /// dimension.
    @inlinable
    public func frame(min size: CGSize?, alignment: Alignment = .center) -> some View {
        frame(minWidth: size?.width, minHeight: size?.height, alignment: alignment)
    }
    
    /// Positions this view within an invisible frame with the specified size.
    ///
    /// Use this method to specify a fixed size for a view's width,
    /// height, or both. If you only specify one of the dimensions, the
    /// resulting view assumes this view's sizing behavior in the other
    /// dimension.
    @inlinable
    public func frame(max size: CGSize?, alignment: Alignment = .center) -> some View {
        frame(maxWidth: size?.width, maxHeight: size?.height, alignment: alignment)
    }
    /// Positions this view within an invisible frame with the specified size.
    ///
    /// Use this method to specify a fixed size for a view's width,
    /// height, or both. If you only specify one of the dimensions, the
    /// resulting view assumes this view's sizing behavior in the other
    /// dimension.
    @inlinable
    public func frame(
        min minSize: CGSize?,
        max maxSize: CGSize?,
        alignment: Alignment = .center
    ) -> some View {
        frame(
            minWidth: minSize?.width,
            maxWidth: maxSize?.width,
            minHeight: minSize?.height,
            maxHeight: maxSize?.height,
            alignment: alignment
        )
    }
}

extension View {
    @inlinable
    public func minWidth(_ width: CGFloat?) -> some View {
        frame(minWidth: width)
    }
    
    @inlinable
    public func maxWidth(_ width: CGFloat?) -> some View {
        frame(maxWidth: width)
    }
    
    @inlinable
    public func minHeight(_ height: CGFloat?) -> some View {
        frame(minHeight: height)
    }
    
    @inlinable
    public func maxHeight(_ height: CGFloat?) -> some View {
        frame(maxHeight: height)
    }
    
    @inlinable
    public func frame(min dimensionLength: CGFloat, axis: Axis) -> some View {
        switch axis {
            case .horizontal:
                return frame(minWidth: dimensionLength)
            case .vertical:
                return frame(minWidth: dimensionLength)
        }
    }
}

extension View {
    /// Positions this view within an invisible frame having the specified ideal size constraints.
    @inlinable
    public func idealFrame(width: CGFloat?, height: CGFloat?) -> some View {
        frame(idealWidth: width, idealHeight: height)
    }
    
    /// Positions this view within an invisible frame having the specified ideal size constraints.
    @inlinable
    public func idealMinFrame(
        width: CGFloat?,
        maxWidth: CGFloat? = nil,
        height: CGFloat?,
        maxHeight: CGFloat? = nil
    ) -> some View {
        frame(
            minWidth: width,
            idealWidth: width,
            maxWidth: maxWidth,
            minHeight: height,
            idealHeight: height,
            maxHeight: maxHeight
        )
    }
}

extension View {
    @inlinable
    public func squareFrame(sideLength: CGFloat?) -> some View {
        frame(width: sideLength, height: sideLength)
    }
    
    @inlinable
    public func squareFrame() -> some View {
        GeometryReader { geometry in
            self.frame(width: geometry.size.minimumDimensionLength, height: geometry.size.minimumDimensionLength)
        }
    }
}

extension View {    
    @inlinable
    public func frameZeroClipped(_ clipped: Bool = true) -> some View {
        frame(clipped ? .zero : nil)
            .clipped()
    }
}
