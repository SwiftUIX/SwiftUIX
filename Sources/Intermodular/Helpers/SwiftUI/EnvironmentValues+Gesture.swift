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
            self[IsEdgePanGestureEnabled]
        } set {
            self[IsEdgePanGestureEnabled] = newValue
        }
    }
}

extension EnvironmentValues {
    struct IsPanGestureEnabled: EnvironmentKey {
        static let defaultValue = true
    }

    public var isPanGestureEnabled: Bool {
        get {
            self[IsPanGestureEnabled]
        } set {
            self[IsPanGestureEnabled] = newValue
        }
    }
}

extension EnvironmentValues {
    struct IsTapGestureEnabled: EnvironmentKey {
        static let defaultValue = true
    }
    
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
