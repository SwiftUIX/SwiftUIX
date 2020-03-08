//
// Copyright (c) Vatsal Manot
//

import SwiftUI

struct IsTapGestureEnabled: EnvironmentKey {
    static let defaultValue = true
}

extension EnvironmentValues {
    public var isTapGestureEnabled: Bool {
        get {
            self[IsTapGestureEnabled]
        } set {
            self[IsTapGestureEnabled] = newValue
        }
    }
}

// MARK: - API -

extension View {
    public func isTapGestureEnabled(_ enabled: Bool) -> some View {
        environment(\.isTapGestureEnabled, enabled)
    }
}
