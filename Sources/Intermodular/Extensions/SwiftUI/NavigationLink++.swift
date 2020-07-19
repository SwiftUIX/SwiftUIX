//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension NavigationLink where Label == Text {
    /// Creates an instance that presents `destination`, with a Text label generated from a title string.
    public init(_ title: LocalizedStringKey, @ViewBuilder destination: () -> Destination) {
        self.init(title, destination: destination())
    }
    
    /// Creates an instance that presents `destination`, with a Text label generated from a title string.
    public init<S: StringProtocol>(_ title: S, @ViewBuilder destination: () -> Destination) {
        self.init(title, destination: destination())
    }
}
