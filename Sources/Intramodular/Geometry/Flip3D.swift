//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

struct Flip3D<Reverse: View>: ViewModifier {
    @Binding private var isFlipped: Bool
    
    private let reverse: Reverse
    private let axis: Axis3D
    
    init(reverse: Reverse, axis: Axis3D, isFlipped: Binding<Bool>) {
        self.reverse = reverse
        self.axis = axis
        self._isFlipped = isFlipped
    }
    
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
    public func flip3D<Reverse: View>(reverse: Reverse, axis: Axis3D = .y, isFlipped: Binding<Bool>) -> some View {
        modifier(Flip3D(reverse: reverse, axis: axis, isFlipped: isFlipped))
    }
}
