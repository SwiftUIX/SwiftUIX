//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension View {
    /// Modifies `self` with a given parameter iff the parameter is not nil.
    public func modifyIfSome<T, V: View>(_ value: T?, _ transform: (Self, T) -> V) -> some View {
        Group {
            if value != nil {
                transform(self, value!)
            } else {
                self
            }
        }
    }
}
