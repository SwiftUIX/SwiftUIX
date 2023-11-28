//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension LazyHGrid {
    public init(
        alignment: Alignment,
        minWidth: CGFloat,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            rows: [
                .adaptive(
                    minimum: minWidth,
                    alignment: alignment
                )
            ],
            spacing: spacing
        ) {
            content()
        }
    }
}
