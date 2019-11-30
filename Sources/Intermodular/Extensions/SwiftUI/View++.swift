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
    @inlinable
    public func frame(_ size: CGSize, alignment: Alignment = .center) -> some View {
        frame(width: size.width, height: size.height, alignment: alignment)
    }
    
    @inlinable
    public func frame(minimum size: CGSize?, alignment: Alignment = .center) -> some View {
        frame(minWidth: size?.width, minHeight: size?.height, alignment: alignment)
    }
    
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
