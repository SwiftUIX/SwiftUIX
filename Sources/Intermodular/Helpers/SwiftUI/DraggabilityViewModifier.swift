//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if !os(tvOS)

/// A view modifier that enables draggability.
public struct DraggabilityViewModifier: ViewModifier {
    @usableFromInline
    let minimumDistance: CGFloat
    
    @usableFromInline
    @State var offset = CGPoint(x: 0, y: 0)
    
    public init(minimumDistance: CGFloat = 0) {
        self.minimumDistance = minimumDistance
    }
    
    @inlinable
    public func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture(minimumDistance: minimumDistance).onChanged { value in
                    self.offset.x += value.location.x - value.startLocation.x
                    self.offset.y += value.location.y - value.startLocation.y
                }
            )
            .offset(x: offset.x, y: offset.y)
    }
}

// MARK: - Helpers -

extension View {
    @inlinable
    public func draggable() -> some View {
        return modifier(DraggabilityViewModifier())
    }
}

#endif
