//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@MainActor
@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension DisclosureGroup {
    public static func _initiallyExpanded(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label
    ) -> some View {
        withInlineState(initialValue: true) { isExpanded in
            DisclosureGroup(
                isExpanded: isExpanded,
                content: content,
                label: label
            )
        }
    }
}
