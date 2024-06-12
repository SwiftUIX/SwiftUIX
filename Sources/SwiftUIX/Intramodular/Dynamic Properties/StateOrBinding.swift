//
// Copyright (c) Vatsal Manot
//

import SwiftUI

/// A property wrapper that can read and write a value from a wrapped `State` or `Binding`.
@propertyWrapper
@frozen
public struct StateOrBinding<Value>: DynamicProperty {
    @usableFromInline
    enum Storage: DynamicProperty {
        case state(State<Value>)
        case binding(Binding<Value>)
    }
    
    @usableFromInline
    var storage: Storage
    
    public var wrappedValue: Value {
        get {
            switch storage {
                case .state(let state):
                    return state.wrappedValue
                case .binding(let binding):
                    return binding.wrappedValue
            }
        }
        nonmutating set {
            switch storage {
                case .state(let state):
                    state.wrappedValue = newValue
                case .binding(let binding):
                    binding.wrappedValue = newValue
            }
        }
    }
    
    public var projectedValue: Binding<Value> {
        switch storage {
            case .state(let state):
                return state.projectedValue
            case .binding(let binding):
                return binding
        }
    }

    @inlinable
    public init(_ value: Value) {
        self.storage = .state(State(initialValue: value))
    }
    
    @inlinable
    public init(_ binding: Binding<Value>) {
        self.storage = .binding(binding)
    }
    
    @inlinable
    public init(_ binding: Binding<Value>?, initialValue: Value) {
        if let binding {
            self.storage = .binding(binding)
        } else {
            self.storage = .state(.init(initialValue: initialValue))
        }
    }
    
    @inlinable
    public init<T>(_ binding: Binding<T?>?) where Value == Optional<T> {
        if let binding {
            self.storage = .binding(binding)
        } else {
            self.storage = .state(.init(initialValue: Value.init(nilLiteral: ())))
        }
    }
}
