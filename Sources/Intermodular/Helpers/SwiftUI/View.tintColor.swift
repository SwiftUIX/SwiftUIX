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

// MARK: - API

extension View {
    /// Sets the tint color of the elements displayed by this view.
    @ViewBuilder
    public func tintColor(_ color: Color?) -> some View {
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            self.tint(color).environment(\.tintColor, color)
        } else {
            self.environment(\.tintColor, color)
        }
    }
}
