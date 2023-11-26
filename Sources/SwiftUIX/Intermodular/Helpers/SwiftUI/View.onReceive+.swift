//
// Copyright (c) Vatsal Manot
//

import Combine
import SwiftUI

/// An extension to the `View` protocol to handle optional publishers.
extension View {
    /// Adds an action to perform when this view detects data emitted by the given publisher.
    /// If the publisher is nil, the action will not be triggered.
    ///
    /// - Parameters:
    ///   - publisher: The optional publisher to subscribe to.
    ///   - action: The closure to execute when a new value is emitted from the publisher.
    ///
    /// - Returns: A view that performs `action` when the `publisher` emits a value.
    ///
    /// - Note: Marked as `_disfavoredOverload` to give priority to SwiftUI's built-in `onReceive(_:perform:)`.
    @_disfavoredOverload
    public func onReceive<P: Publisher>(
        _ publisher: P?,
        perform action: @escaping (P.Output) -> Void
    ) -> some View where P.Failure == Never {
        self.background {
            if let publisher {
                ZeroSizeView()
                    .onReceive(publisher, perform: action)
            }
        }
    }
}
