//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension View {
    public func then(_ body: (inout Self) -> Void) -> Self {
        var result = self
        
        body(&result)
        
        return result
    }
    
    /// Returns a type-erased version of `self`.
    @inlinable
    public func eraseToAnyView() -> AnyView {
        return .init(self)
    }
}

extension View {
    @inlinable
    public func backgroundColor(_ color: Color) -> some View {
        background(color.edgesIgnoringSafeArea(.all))
    }
    
    public func backgroundPreference<K: PreferenceKey>(key _: K.Type = K.self, value: K.Value) -> some View {
        background(EmptyView().preference(key: K.self, value: value))
    }
}

extension View {
    public func bottomTrailing() -> some View {
        ZStack {
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    self
                }
            }
        }
    }
}

extension View {
    public func inset(_ point: CGPoint) -> some View {
        return offset(x: -point.x, y: -point.y)
    }
    
    public func offset(_ point: CGPoint) -> some View {
        return offset(x: point.x, y: point.y)
    }
}

extension View {
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
    
    public func relativeSize(
        width widthRatio: CGFloat,
        height heightRatio: CGFloat,
        alignment: Alignment = .center
    ) -> some View {
        GeometryReader { geometry in
            self.frame(
                width: geometry.size.width * widthRatio,
                height: geometry.size.height * heightRatio,
                alignment: alignment
            )
        }
    }
    
    /// Causes the view to fill into its superview.
    public func fill(alignment: Alignment = .center) -> some View {
        relativeSize(width: 1.0, height: 1.0)
    }
    
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
    public func frame(minimum dimensionLength: CGFloat, axis: Axis) -> some View {
        switch axis {
            case .horizontal:
                return frame(minWidth: dimensionLength)
            case .vertical:
                return frame(minWidth: dimensionLength)
        }
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
    public func frame(minimum size: CGSize?, alignment: Alignment = .center) -> some View {
        frame(minWidth: size?.width, minHeight: size?.height, alignment: alignment)
    }
    
    /// Positions this view within an invisible frame with the specified size.
    ///
    /// Use this method to specify a fixed size for a view's width,
    /// height, or both. If you only specify one of the dimensions, the
    /// resulting view assumes this view's sizing behavior in the other
    /// dimension.
    @inlinable
    public func frame(
        minimum minSize: CGSize?,
        maximum maxSize: CGSize?,
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
    
    @inlinable
    public func frameZeroClipped(_ isZeroClipped: Bool = true) -> some View {
        frame(isZeroClipped ? CGSize.zero : nil)
            .clipped()
    }
}

extension View {
    public func width(_ width: CGFloat?) -> some View {
        frame(width: width)
    }
    
    public func height(_ height: CGFloat?) -> some View {
        frame(height: height)
    }
    
    public func maxWidth(_ width: CGFloat?) -> some View {
        frame(maxWidth: width)
    }
    
    public func maxHeight(_ height: CGFloat?) -> some View {
        frame(maxHeight: height)
    }
    
    public func square(_ sideLength: CGFloat?) -> some View {
        frame(width: sideLength, height: sideLength)
    }
}

extension View {
    public func hidden(_ isHidden: Bool) -> some View {
        Group {
            if isHidden {
                hidden()
            } else {
                self
            }
        }
    }
}

#if os(macOS)

extension View {
    @available(*, deprecated, message: "This function is currently unavailable on macOS.")
    public func navigationBarTitle(_ title: String) -> some View {
        return self
    }
    
    @available(*, deprecated, message: "This function is currently unavailable on macOS.")
    public func navigationBarItems<V: View>(trailing: V) -> some View {
        return self
    }
}

#endif
