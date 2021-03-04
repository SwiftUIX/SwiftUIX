//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

private struct RemoveIfNotInDisplay: ViewModifier {
    @inline(never)
    @State var isInDisplay: Bool = false
    
    @inline(never)
    func body(content: Content) -> some View {
        PassthroughView {
            if isInDisplay {
                content
            } else {
                ZeroSizeView()
            }
        }
        .isInDisplay($isInDisplay)
    }
}

extension View {
    /// Removes the view from the view hierarchy if the parent view is not in display.
    @inline(never)
    public func removeIfNotInDisplay() -> some View {
        modifier(RemoveIfNotInDisplay())
    }
}

extension View {
    /// A binding that updates when the view appears or disappears. The binding's value is set to `true` when the view appears, and `false` when the view disappears.
    @ViewBuilder
    public func isInDisplay(_ isInDisplay: Binding<Bool>) -> some View {
        onAppear {
            isInDisplay.wrappedValue = true
        }
        .onDisappear {
            isInDisplay.wrappedValue = false
        }
    }
}
