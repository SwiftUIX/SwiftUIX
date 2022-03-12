//
// Copyright (c) Vatsal Manot
//

import SwiftUI

extension View {
    /// Adds an action to perform when the _background_ of this view recognizes a tap gesture.
    @available(tvOS, unavailable)
    public func onTapGestureOnBackground(
        count: Int = 1,
        perform action: @escaping () -> Void
    ) -> some View {
        background {
            Color.almostClear.onTapGesture(count: count, perform: action)
        }
    }
}
