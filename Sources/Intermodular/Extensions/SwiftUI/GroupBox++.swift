//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@available(iOS 14.0, macOS 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension GroupBox where Label == AnyView {
    @_disfavoredOverload
    public init<S: StringProtocol>(
        _ title: S,
        @ViewBuilder content: () -> Content
    ) {
        self.init {
            Text(title)
                .padding(.bottom, 1)
                .eraseToAnyView()
        } content: {
            content()
        }
    }
}

@available(iOS 14.0, macOS 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension GroupBox {
    public init(@ViewBuilder label: () -> Label, @ViewBuilder content: () -> Content) {
        self.init(label: label(), content: content)
    }
}
