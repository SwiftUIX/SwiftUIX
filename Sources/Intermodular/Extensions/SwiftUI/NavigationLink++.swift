//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension NavigationLink {
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    public init(
        _isActive isActive: Binding<Bool>,
        @ViewBuilder destination: () -> Destination,
        @ViewBuilder label: () -> Label
    ) {
        self.init(
            isActive: isActive,
            destination: destination,
            label: label
        )
    }
}

extension NavigationLink {
    @_disfavoredOverload
    public init(
        @ViewBuilder destination: () -> Destination,
        @ViewBuilder label: () -> Label
    ) {
        self.init(destination: destination(), label: label)
    }
}

extension NavigationLink where Label == Text {
    /// Creates an instance that presents `destination`, with a Text label generated from a title string.
    public init(_ title: LocalizedStringKey, @ViewBuilder destination: () -> Destination) {
        self.init(title, destination: destination())
    }
    
    /// Creates an instance that presents `destination`, with a Text label generated from a title string.
    public init<S: StringProtocol>(_ title: S, @ViewBuilder destination: () -> Destination) {
        self.init(title, destination: destination())
    }
    
    @_disfavoredOverload
    public init(
        _ title: String,
        isActive: Binding<Bool>,
        @ViewBuilder destination: () -> Destination
    ) {
        self.init(title, destination: destination(), isActive: isActive)
    }
}
