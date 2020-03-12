//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

private final class PreferredMaximumLayoutHeight: DefaultEnvironmentKey<CGFloat> {
    
}

extension EnvironmentValues {
    public var preferredMaximumLayoutHeight: CGFloat? {
        get {
            self[PreferredMaximumLayoutHeight]
        } set {
            self[PreferredMaximumLayoutHeight] = newValue
        }
    }
}

// MARK: - API -

extension View {
    public func preferredMaximumLayoutHeight(_ preferredMaximumLayoutHeight: CGFloat) -> some View {
        environment(\.preferredMaximumLayoutHeight, preferredMaximumLayoutHeight)
    }
}
