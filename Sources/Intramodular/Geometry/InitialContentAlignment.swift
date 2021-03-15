//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

private struct InitialContentAlignmentEnvironmentKey: EnvironmentKey {
    static let defaultValue: Alignment? = nil
}

extension EnvironmentValues {
    public var initialContentAlignment: Alignment? {
        get {
            self[InitialContentAlignmentEnvironmentKey]
        } set {
            self[InitialContentAlignmentEnvironmentKey] = newValue
        }
    }
}

// MARK: - API -

extension View {
    @inlinable
    public func initialContentAlignment(_ alignment: Alignment) -> some View {
        environment(\.initialContentAlignment, alignment)
    }
}
