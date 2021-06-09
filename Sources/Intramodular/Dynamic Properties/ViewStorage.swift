//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

@propertyWrapper
public struct ViewStorage<Value>: DynamicProperty {
    private final class ValueBox {
        var value: Value
        
        init(_ value: Value) {
            self.value = value
        }
    }
    
    @State private var valueBox: ValueBox
    
    public var wrappedValue: Value {
        get {
            valueBox.value
        } nonmutating set {
            valueBox.value = newValue
        }
    }
    
    public init(wrappedValue value: @autoclosure @escaping () -> Value) {
        self._valueBox = .init(wrappedValue: ValueBox(value()))
    }
}
