//
// Copyright (c) Vatsal Manot
//

import SwiftUI

struct IsEdgePanGestureEnabled: EnvironmentKey {
    static let defaultValue = true
}

extension EnvironmentValues {
    public var isEdgePanGestureEnabled: Bool {
        get {
            self[IsEdgePanGestureEnabled]
        } set {
            self[IsEdgePanGestureEnabled] = newValue
        }
    }
}

// MARK: - API -

extension View {
    public func isEdgePanGestureEnabled(_ enabled: Bool) -> some View {
        environment(\.isEdgePanGestureEnabled, enabled)
    }
}
