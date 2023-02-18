//
// Copyright (c) Vatsal Manot
//

import SwiftUI

extension EnvironmentValues {
    struct IsEdgePanGestureEnabled: EnvironmentKey {
        static let defaultValue = true
    }
    
    public var isEdgePanGestureEnabled: Bool {
        get {
            self[IsEdgePanGestureEnabled.self]
        } set {
            self[IsEdgePanGestureEnabled.self] = newValue
        }
    }
}

extension EnvironmentValues {
    struct IsPanGestureEnabled: EnvironmentKey {
        static let defaultValue = true
    }

    public var isPanGestureEnabled: Bool {
        get {
            self[IsPanGestureEnabled.self]
        } set {
            self[IsPanGestureEnabled.self] = newValue
        }
    }
}

extension EnvironmentValues {
    struct IsTapGestureEnabled: EnvironmentKey {
        static let defaultValue = true
    }
    
    public var isTapGestureEnabled: Bool {
        get {
            self[IsTapGestureEnabled.self]
        } set {
            self[IsTapGestureEnabled.self] = newValue
        }
    }
}

// MARK: - API

extension View {
    public func isEdgePanGestureEnabled(_ enabled: Bool) -> some View {
        environment(\.isEdgePanGestureEnabled, enabled)
    }

    public func isPanGestureEnabled(_ enabled: Bool) -> some View {
        environment(\.isPanGestureEnabled, enabled)
    }
    
    public func isTapGestureEnabled(_ enabled: Bool) -> some View {
        environment(\.isTapGestureEnabled, enabled)
    }
}
