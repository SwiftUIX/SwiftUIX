//
// Copyright (c) Vatsal Manot
//

import SwiftUI

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension ContentUnavailableView where Label == Text, Description == EmptyView, Actions == EmptyView {
    public init(_ title: String) {
        self.init(
            label: {
                Text(title)
            },
            description: { EmptyView() },
            actions: { EmptyView() }
        )
    }
}
