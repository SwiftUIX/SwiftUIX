//
// Copyright (c) Vatsal Manot
//

import Dispatch
import Swift
import SwiftUI

@propertyWrapper
public struct LazyState<Value>: DynamicProperty {
    private let initialWrappedValue: () -> Value
    
    private var _cachedWrappedValue: Value?
    
    @State private var _wrappedValue: Value? = nil
    
    /// The current state value.
    public var wrappedValue: Value {
        get {
            _wrappedValue ?? _cachedWrappedValue ?? initialWrappedValue()
        } nonmutating set {
            _wrappedValue = newValue
        }
    }
    
    /// The binding value, as "unwrapped" by accessing `$foo` on a `@Binding` property.
    public var projectedValue: Binding<Value> {
        return .init(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0 }
        )
    }
    
    /// Initialize with the provided initial value.
    public init(initial: @escaping () -> Value) {
        self.initialWrappedValue = initial
    }
    
    public mutating func update() {
        guard _cachedWrappedValue == nil else {
            return
        }
        
        let value = initialWrappedValue()
                
        _cachedWrappedValue = value
    }
}
