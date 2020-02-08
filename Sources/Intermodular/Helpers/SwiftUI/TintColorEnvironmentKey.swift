//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

struct TintColorEnvironmentKey: EnvironmentKey {
    static let defaultValue: Color? = nil
}

extension EnvironmentValues {
    var tintColor: Color? {
        get {
            self[TintColorEnvironmentKey]
        } set {
            self[TintColorEnvironmentKey] = newValue
        }
    }
}

// MARK: - API -

extension View {
    public func tintColor(_ color: Color) -> some View {
        accentColor(color)
            .environment(\.tintColor, color)
    }
}
