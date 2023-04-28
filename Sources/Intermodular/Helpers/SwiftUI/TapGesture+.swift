//
// Copyright (c) Vatsal Manot
//

import SwiftUI

extension View {
    @available(tvOS, unavailable)
    public func onTapGesture(
        count: Int = 1,
        disabled: Bool,
        perform: @escaping () -> Void
    ) -> some View {
        gesture(
            TapGesture(count: count).onEnded(perform),
            including: disabled ? .subviews : .all
        )
    }

    /// Adds an action to perform when the _background_ of this view recognizes a tap gesture.
    @available(tvOS, unavailable)
    public func onTapGestureOnBackground(
        count: Int = 1,
        perform action: @escaping () -> Void
    ) -> some View {
        if #available(iOS 13.0, macOS 10.15, tvOS 16.0, watchOS 6.0, *) {
            return background {
                Color.almostClear
                    .contentShape(Rectangle())
                    .onTapGesture(count: count, perform: action)
            }
            .eraseToAnyView()
        } else {
            return self.eraseToAnyView()
        }
    }
}
