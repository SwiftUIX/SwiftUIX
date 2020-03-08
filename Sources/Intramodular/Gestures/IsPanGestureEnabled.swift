//
// Copyright (c) Vatsal Manot
//

import SwiftUI

struct IsPanGestureEnabled: EnvironmentKey {
    static let defaultValue = true
}

struct IsTapGestureEnabled: EnvironmentKey {
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
    public func isPanGestureEnabled(_ enabled: Bool) -> some View {
        environment(\.isPanGestureEnabled, enabled)
    }
}

extension View {
    public func isTapGestureEnabled(_ enabled: Bool) -> some View {
        environment(\.isTapGestureEnabled, enabled)
    }
}
