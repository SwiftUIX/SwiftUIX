//
// Copyright (c) Vatsal Manot
//

import SwiftUI

struct IsScrollEnabledEnvironmentKey: EnvironmentKey {
    static let defaultValue = true
}

extension EnvironmentValues {
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
    public func isScrollEnabled(_ isEnabled: Bool) -> some View {
        environment(\.isScrollEnabled, isEnabled)
    }
}
