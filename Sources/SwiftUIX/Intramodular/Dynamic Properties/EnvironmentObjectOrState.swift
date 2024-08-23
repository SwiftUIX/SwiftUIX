//
// Copyright (c) Vatsal Manot
//

import Combine
import Dispatch
import Swift
import SwiftUI

@propertyWrapper
@_documentation(visibility: internal)
public struct EnvironmentObjectOrState<Value: ObservableObject>: DynamicProperty {
    @EnvironmentObject<Value>
    private var _wrappedValue0: Value
    @State
    private var _wrappedValue1: Value?
    
    public var wrappedValue: Value {
        get {
            _wrappedValue1 ?? _wrappedValue0
        } nonmutating set {
            _wrappedValue1 = newValue
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
    public init(wrappedValue value: Value) {
        self.__wrappedValue1 = .init(initialValue: value)
    }
    
    public init() {
        
    }
    
    public mutating func update() {
        self.__wrappedValue0.update()
        self.__wrappedValue1.update()
    }
}
