//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if (os(iOS) || os(macOS) || targetEnvironment(macCatalyst)) && swift(>=5.2)

@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension View {
    @inlinable
    @ViewBuilder
    public func onDragIfAvailable(_ data: @escaping () -> NSItemProvider) -> some View {
        #if swift(<5.3)
        guard #available(iOS 13.4, *) else {
            self
        }
        
        self.onDrag(data)
        #else
        if #available(iOS 13.4, *) {
            self.onDrag(data)
        } else {
            self
        }
        #endif
    }
}

#endif
