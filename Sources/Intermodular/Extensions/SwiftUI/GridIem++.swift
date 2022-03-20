//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension GridItem {
    public static func flexible(
        spacing: CGFloat? = nil,
        alignment: Alignment? = nil
    ) -> Self {
        GridItem(.flexible(), spacing: spacing, alignment: alignment)
    }
}
