//
// Copyright (c) Vatsal Manot
//

import SwiftUI

struct IsPanGestureEnabled: EnvironmentKey {
    static let defaultValue = true
}

extension EnvironmentValues {
    public var isPanGestureEnabled: Bool {
        get {
            self[IsPanGestureEnabled]
        } set {
            self[IsPanGestureEnabled] = newValue
        }
    }
}

// MARK: - API -

extension View {
    public func isPanGestureEnabled(_ enabled: Bool) -> some View {
        environment(\.isPanGestureEnabled, enabled)
    }
}
