//
// Copyright (c) Vatsal Manot
//

import SwiftUI

extension View {
    public func _scrollBounceBehaviorBasedOnSizeIfAvailable(
        axes: Axis.Set = []
    ) -> some View {
        modify {
            if #available(iOS 16.4, macOS 13.3, tvOS 16.4, watchOS 9.4, *) {
                $0.scrollBounceBehavior(.basedOnSize, axes: axes)
            } else {
                $0
            }
        }
    }
}
