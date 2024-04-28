//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension GridItem {
    public static func flexible(
        minimum: CGFloat = 10,
        maximum: CGFloat = .infinity,
        spacing: CGFloat? = nil,
        alignment: Alignment? = nil
    ) -> Self {
        GridItem(
            .flexible(),
            spacing: spacing,
            alignment: alignment
        )
    }
    
    public static func adaptive(
        minimum: CGFloat,
        maximum: CGFloat = .infinity,
        spacing: CGFloat? = nil,
        alignment: Alignment? = nil
    ) -> Self {
        GridItem(
            .adaptive(minimum: minimum, maximum: maximum),
            spacing: spacing,
            alignment: alignment
        )
    }
    
    public static func adaptive(
        width: CGFloat,
        spacing: CGFloat? = nil,
        alignment: Alignment? = nil
    ) -> Self {
        GridItem(
            .adaptive(minimum: width, maximum: width),
            spacing: spacing,
            alignment: alignment
        )
    }
}
