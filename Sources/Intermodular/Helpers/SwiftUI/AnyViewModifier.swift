//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A type-erased view modifier.
public struct AnyViewModifier: ViewModifier {
    private let makeBody: (Content) -> AnyView

    public init<T: ViewModifier>(_ modifier: T) {
        self.makeBody = { $0.modifier(modifier).eraseToAnyView() }
    }

    public init<Body: View>(
        @ViewBuilder _ makeBody: @escaping (Content) -> Body
    ) {
        self.makeBody = { makeBody($0).eraseToAnyView() }
    }

    public func body(content: Content) -> some View {
        makeBody(content)
    }
}
