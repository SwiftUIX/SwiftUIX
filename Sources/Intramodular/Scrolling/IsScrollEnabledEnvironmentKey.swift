//
// Copyright (c) Vatsal Manot
//

import SwiftUI

extension EnvironmentValues {
    private struct IsScrollEnabledEnvironmentKey: EnvironmentKey {
        static let defaultValue = true
    }
    
    public var isScrollEnabled: Bool {
        get {
            self[IsScrollEnabledEnvironmentKey]
        } set {
            self[IsScrollEnabledEnvironmentKey] = newValue
        }
    }
}

// MARK: - API -

extension View {
    /// Adds a condition that controls whether users can scroll within this view.
    public func scrollDisabled(_ disabled: Bool) -> some View {
        environment(\.isScrollEnabled, !disabled)
    }
    
    @available(*, message: "isScrollEnabled(_:) is deprecated, use scrollDisabled(_:) instead")
    public func isScrollEnabled(_ isEnabled: Bool) -> some View {
        environment(\.isScrollEnabled, isEnabled)
    }
}
