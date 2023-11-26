//
// Copyright (c) Vatsal Manot
//

import Dispatch
import Swift
import SwiftUI

@propertyWrapper
public struct DelayedState<Value>: DynamicProperty {
    @inlinable
    @State public var _wrappedValue: Value
    
    /// The current state value.
    @inlinable
    public var wrappedValue: Value {
        get {
            _wrappedValue
        } nonmutating set {
            DispatchQueue.main.async {
                self._wrappedValue = newValue
            }
        }
    }
    
    @inlinable
    public var unsafelyUnwrapped: Value {
        get {
            _wrappedValue
        } nonmutating set {
            _wrappedValue = newValue
        }
    }
    
    /// The binding value, as "unwrapped" by accessing `$foo` on a `@Binding` property.
    @inlinable
    public var projectedValue: Binding<Value> {
        return .init(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0 }
        )
    }
    
    /// Initialize with the provided initial value.
    public init(wrappedValue value: Value) {
        self.__wrappedValue = .init(initialValue: value)
    }
}
