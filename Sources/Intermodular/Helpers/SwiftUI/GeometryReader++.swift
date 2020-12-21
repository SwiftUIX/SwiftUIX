//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension GeometryReader {
    @inlinable
    public init<T: View>(
        alignment: Alignment,
        @ViewBuilder content: @escaping (GeometryProxy) -> T
    ) where Content == XStack<T> {
        self.init { geometry in
            XStack(alignment: alignment) {
                content(geometry)
            }
        }
    }
}
