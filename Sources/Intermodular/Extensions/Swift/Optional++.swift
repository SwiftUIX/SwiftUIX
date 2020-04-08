//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension Optional {
    /// Evaluates the given closure when this `Optional` instance is not `nil`,
    /// passing the unwrapped value as a parameter.
    ///
    /// Use the `map` method with a closure that returns a non-optional view.
    @inlinable
    public func map<V: View>(@ViewBuilder _ transform: (Wrapped) throws -> V) rethrows -> V? {
        if let wrapped = self {
            return try transform(wrapped)
        } else {
            return nil
        }
    }
    
    /// Evaluates the given closure when this `Optional` instance is not `nil`,
    /// passing the unwrapped value as a parameter.
    ///
    /// Use the `flatMap` method with a closure that returns an optional view.
    @inlinable
    public func flatMap<V: View>(@ViewBuilder _ transform: (Wrapped) throws -> V?) rethrows -> V? {
        if let wrapped = self {
            return try transform(wrapped)
        } else {
            return nil
        }
    }
}

extension Optional where Wrapped: View {
    @inlinable
    public static func ?? <V: View>(lhs: Self, rhs: @autoclosure () -> V) -> _ConditionalContent<Self, V> {
        if let wrapped = lhs {
            return ViewBuilder.buildEither(first: wrapped)
        } else {
            return ViewBuilder.buildEither(second: rhs())
        }
    }
}
