//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

fileprivate struct Flip3D<Reverse: View>: ViewModifier {
    let isFlipped: Bool
    let reverse: Reverse
    let axis: Axis3D
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .hidden(isFlipped)
            
            reverse
                .mirror3D(axis: axis)
                .hidden(!isFlipped)
        }
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: axis)
    }
}

// MARK: - Helpers -

extension View {
    /// Flips this view.
    public func flip3D<Reverse: View>(
        _ flip: Bool = true, axis: Axis3D = .y, reverse: Reverse
    ) -> some View {
        modifier(Flip3D(isFlipped: flip, reverse: reverse, axis: axis))
    }
}
