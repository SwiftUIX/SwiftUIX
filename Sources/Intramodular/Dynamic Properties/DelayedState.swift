//
// Copyright (c) Vatsal Manot
//

import Dispatch
import Swift
import SwiftUI

@propertyWrapper
public struct DelayedState<Value>: DynamicProperty {
    @State private var _wrappedValue: Value
    
    /// The current state value.
    public var wrappedValue: Value {
        get {
            _wrappedValue
        } nonmutating set {
            DispatchQueue.main.async {
                self._wrappedValue = newValue
            }
        }
    }
    
    /// Initialize with the provided initial value.
    public init(wrappedValue value: Value) {
        self.__wrappedValue = .init(initialValue: value)
    }
        
    public mutating func update() {
        self.__wrappedValue.update()
    }
    
    /// The binding value, as "unwrapped" by accessing `$foo` on a `@Binding` property.
    public var projectedValue: Binding<Value> {
        return .init(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0 }
        )
    }
}
