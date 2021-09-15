//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension View {
    /// Masks the given view using the alpha channel of this view.
    @inlinable
    public func masking<T: View>(_ view: T) -> some View {
        hidden().background(view.mask(self))
    }
    
    /// https://www.fivestars.blog/articles/reverse-masks-how-to/
    @inlinable
    public func reverseMask<Mask: View>(alignment: Alignment = .center, @ViewBuilder _ mask: () -> Mask) -> some View {
        self.mask(
            Rectangle()
                .overlay(alignment: alignment) {
                    mask()
                        .blendMode(.destinationOut)
                }
        )
    }
}
