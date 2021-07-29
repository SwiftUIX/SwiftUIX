//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension EnvironmentValues {
    private struct TintColor: EnvironmentKey {
        static let defaultValue: Color? = nil
    }
    
    public var tintColor: Color? {
        get {
            self[TintColor.self]
        } set {
            self[TintColor.self] = newValue
        }
    }
}

// MARK: - API -

extension View {
    /// Sets the tint color of the elements displayed by this view.
    @inlinable
    public func tintColor(_ color: Color?) -> some View {
        environment(\.tintColor, color)
    }
}
