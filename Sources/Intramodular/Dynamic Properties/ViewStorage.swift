//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

@propertyWrapper
public struct ViewStorage<Value>: DynamicProperty {
    private final class ValueBox: ObservableObject {
        @Published var value: Value
        
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
    
    public var projectedValue: ViewStorage<Value> {
        self
    }
    
    public init(wrappedValue value: @autoclosure @escaping () -> Value) {
        self._valueBox = .init(wrappedValue: ValueBox(value()))
    }
}

extension ViewStorage {
    public var binding: Binding<Value> {
        .init(
            get: { self.valueBox.value },
            set: { self.valueBox.value = $0 }
        )
    }
    
    public var publisher: Published<Value>.Publisher {
        valueBox.$value
    }
}
