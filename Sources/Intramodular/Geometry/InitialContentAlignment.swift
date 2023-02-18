//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension EnvironmentValues {
    private struct InitialContentAlignmentKey: EnvironmentKey {
        static let defaultValue: Alignment? = nil
    }
    
    public var initialContentAlignment: Alignment? {
        get {
            self[InitialContentAlignmentKey.self]
        } set {
            self[InitialContentAlignmentKey.self] = newValue
        }
    }
}

// MARK: - API

extension View {
    public func initialContentAlignment(_ alignment: Alignment) -> some View {
        environment(\.initialContentAlignment, alignment)
    }
}
