//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

@propertyWrapper
public struct ViewStorage<Value>: DynamicProperty {
    fileprivate final class ValueBox: ObservableValue<Value> {
        @Published var value: Value
        
        override var wrappedValue: Value {
            get {
                value
            } set {
                value = newValue
            }
        }
        
        init(_ value: Value) {
            self.value = value
            
            super.init()
        }
    }
    
    @State fileprivate var valueBox: ValueBox
    
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

// MARK: - API -

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

extension ObservedValue {
    public init(_ storage: ViewStorage<Value>) {
        self.init(base: storage.valueBox)
    }
}
