//
// Copyright (c) Vatsal Manot
//

import SwiftUI

extension View {
    @available(iOS 13.0, macOS 10.15, tvOS 16.0, watchOS 6.0, *)
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
    @available(iOS 13.0, macOS 10.15, tvOS 16.0, watchOS 6.0, *)
    public func onTapGestureOnBackground(
        count: Int = 1,
        perform action: @escaping () -> Void
    ) -> some View {
        background {
            Color.almostClear
                .contentShape(Rectangle())
                .onTapGesture(count: count, perform: action)
        }
    }
}

#if os(iOS)
extension View {
    @available(iOS 13.0, macOS 10.15, tvOS 16.0, watchOS 6.0, *)
    public func onTapGesture(
        count: Int = 1,
        modifiers: EventModifiers,
        perform: @escaping () -> Void
    ) -> some View {
        gesture(
            TapGesture(count: count)
                .onEnded(perform)
        )
    }
}
#elseif os(macOS)
extension View {
    @available(iOS 13.0, macOS 10.15, tvOS 16.0, watchOS 6.0, *)
    public func onTapGesture(
        count: Int = 1,
        modifiers: EventModifiers,
        perform: @escaping () -> Void
    ) -> some View {
        gesture(
            TapGesture(count: count)
                .modifiers(modifiers)
                .onEnded(perform)
        )
    }
}
#endif
