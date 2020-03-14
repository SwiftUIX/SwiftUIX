//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

private struct AdjustsFontSizeToFitWidth: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    public var adjustsFontSizeToFitWidth: Bool {
        get {
            self[AdjustsFontSizeToFitWidth]
        } set {
            self[AdjustsFontSizeToFitWidth] = newValue
        }
    }
}

// MARK: - API -

extension View {
    public func adjustsFontSizeToFitWidth(_ adjustsFontSizeToFitWidth: Bool) -> some View {
        environment(\.adjustsFontSizeToFitWidth, adjustsFontSizeToFitWidth)
    }
}
