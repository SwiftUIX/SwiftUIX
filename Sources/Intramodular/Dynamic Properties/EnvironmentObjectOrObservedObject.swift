//
// Copyright (c) Vatsal Manot
//

import Dispatch
import Swift
import SwiftUI

@propertyWrapper
public struct EnvironmentObjectOrObservedObject<Value: ObservableObject>: DynamicProperty {
    let defaultValue: () -> Value
    
    @OptionalEnvironmentObject<Value> private var _wrappedValue0: Value?
    @OptionalObservedObject private var _wrappedValue1: Value?
    
    public var wrappedValue: Value {
        get {
            if let result = _wrappedValue1 ?? _wrappedValue0 {
                return result
            } else {
                assertionFailure()
                
                return defaultValue()
            }
        } set {
            _wrappedValue1 = newValue
        }
    }
    
    /// Initialize with the provided initial value.
    public init(defaultValue: @autoclosure @escaping () -> Value) {
        self.defaultValue = defaultValue
    }
    
    public mutating func update() {
        if _wrappedValue0 == nil {
            _wrappedValue1 = defaultValue()
        }
        
        self.__wrappedValue0.update()
        self.__wrappedValue1.update()
    }
}
