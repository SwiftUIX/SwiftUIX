//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension View {
    /// Masks this view using the alpha channel of the given view.
    @_disfavoredOverload
    @inlinable
    public func mask<T: View>(@ViewBuilder _ view: () -> T) -> some View {
        self.mask(view())
    }

    /// Masks the given view using the alpha channel of this view.
    @inlinable
    public func masking<T: View>(_ view: T) -> some View {
        hidden().background(view.mask(self))
    }
    
    /// Masks the given view using the alpha channel of this view.
    @inlinable
    public func masking<T: View>(@ViewBuilder _ view: () -> T) -> some View {
        masking(view())
    }

    /// https://www.fivestars.blog/articles/reverse-masks-how-to/
    @inlinable
    public func reverseMask<Mask: View>(
        alignment: Alignment = .center,
        @ViewBuilder _ mask: () -> Mask
    ) -> some View {
        self.mask(
            Rectangle()
                .overlay(mask().blendMode(.destinationOut), alignment: alignment)
        )
    }
}
