//
// Copyright (c) Vatsal Manot
//

import SwiftUI

fileprivate struct ForegroundColorEnvironmentKeys {
    struct Primary: EnvironmentKey {
        public static var defaultValue: Color = .primary
    }
    
    struct Secondary: EnvironmentKey {
        public static var defaultValue: Color = .secondary
    }
    
    struct Action: EnvironmentKey {
        public static var defaultValue: Color = .primary
    }
}

extension EnvironmentValues {
    public var primaryForegroundColor: Color {
        get {
            self[ForegroundColorEnvironmentKeys.Primary]
        } set {
            self[ForegroundColorEnvironmentKeys.Primary] = newValue
        }
    }
    
    public var secondaryForegroundColor: Color {
        get {
            self[ForegroundColorEnvironmentKeys.Secondary]
        } set {
            self[ForegroundColorEnvironmentKeys.Secondary] = newValue
        }
    }
    
    public var actionForegroundColor: Color {
        get {
            self[ForegroundColorEnvironmentKeys.Action]
        } set {
            self[ForegroundColorEnvironmentKeys.Action] = newValue
        }
    }
}

extension View {
    /// Set the primary foreground color within `self`.
    public func primaryForegroundColor(_ color: Color) -> some View {
        environment(\.primaryForegroundColor, color)
    }
    
    /// Set the secondary foreground color within `self`.
    public func secondaryForegroundColor(_ color: Color) -> some View {
        environment(\.secondaryForegroundColor, color)
    }
    
    /// Set the action foreground color within `self`.
    public func actionForegroundColor(_ color: Color) -> some View {
        environment(\.actionForegroundColor, color)
    }
}
