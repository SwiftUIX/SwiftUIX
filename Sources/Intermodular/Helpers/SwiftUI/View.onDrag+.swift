//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if (os(iOS) || os(macOS) || targetEnvironment(macCatalyst)) && swift(>=5.2)

@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension View {
    @_optimize(none)
    @inline(never)
    @ViewBuilder
    public func onDragIfAvailable(_ data: @escaping () -> NSItemProvider) -> some View {
        if #available(iOS 13.4, *) {
            return self.onDrag(data)
        } else {
            return self
        }
    }
}

#endif
