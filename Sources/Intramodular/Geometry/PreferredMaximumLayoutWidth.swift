//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

private final class PreferredMaximumLayoutWidth: DefaultEnvironmentKey<CGFloat> {
    
}

extension EnvironmentValues {
    public var preferredMaximumLayoutWidth: CGFloat? {
        get {
            self[PreferredMaximumLayoutWidth]
        } set {
            self[PreferredMaximumLayoutWidth] = newValue
        }
    }
}

// MARK: - API -

extension View {
    public func preferredMaximumLayoutWidth(_ preferredMaximumLayoutWidth: CGFloat) -> some View {
        environment(\.preferredMaximumLayoutWidth, preferredMaximumLayoutWidth)
    }
}
