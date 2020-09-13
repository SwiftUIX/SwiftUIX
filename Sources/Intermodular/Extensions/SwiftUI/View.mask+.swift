//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension View {
    /// Masks the given view using the alpha channel of this view.
    public func masking<T: View>(_ view: T) -> some View {
        hidden().background(view.mask(self))
    }
}
