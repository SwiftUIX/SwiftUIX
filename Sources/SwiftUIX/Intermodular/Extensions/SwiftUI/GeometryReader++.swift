//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension GeometryReader {
    @inlinable
    public init<T: View>(
        alignment: Alignment,
        @ViewBuilder content: @escaping (GeometryProxy) -> T
    ) where Content == XStack<T> {
        self.init { geometry in
            XStack(alignment: alignment) {
                content(geometry)
            }
        }
    }
}

extension GeometryProxy {
    public func convert(
        _ coordinate: CGPoint,
        from coordinateSpace: CoordinateSpace
    ) -> CGPoint {
        let frame = self.frame(in: coordinateSpace)
        
        return CGPoint(
            x: coordinate.x - frame.origin.x,
            y: coordinate.y - frame.origin.y
        )
    }
}
