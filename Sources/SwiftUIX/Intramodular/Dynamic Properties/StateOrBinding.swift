//
// Copyright (c) Vatsal Manot
//

import SwiftUI

/// A property wrapper that can read and write a value from a wrapped `State` or `Binding`.
@propertyWrapper
@frozen
@_documentation(visibility: internal)
public struct StateOrBinding<Value>: DynamicProperty {
    @usableFromInline
    enum Storage: DynamicProperty {
        case state(State<Value>)
        case binding(Binding<Value>)
    }
    
    public class _DetachedValueBox: ObservableObject {        
        @Published var wrappedValue: Value
        
        @usableFromInline
        init(wrappedValue: Value) {
            self.wrappedValue = wrappedValue
        }
    }

    @usableFromInline
    var initialValue: Value
    @usableFromInline
    var storage: Storage
        
    private var __detachedValueBox: _DetachedValueBox?
    
    public mutating func detach() {
        __detachedValueBox = _DetachedValueBox(wrappedValue: initialValue)
    }
    
    public var wrappedValue: Value {
        get {
            if let __detachedValueBox {
                return __detachedValueBox.wrappedValue
            } else {
                switch storage {
                    case .state(let state):
                        return state.wrappedValue
                    case .binding(let binding):
                        return binding.wrappedValue
                }
            }
        } nonmutating set {
            if let __detachedValueBox {
                __detachedValueBox.wrappedValue = newValue
            }

            switch storage {
                case .state(let state):
                    guard __detachedValueBox == nil else {
                        return
                    }
                    
                    state.wrappedValue = newValue
                case .binding(let binding):
                    binding.wrappedValue = newValue
            }
        }
    }
    
    public var projectedValue: Binding<Value> {
        if let __detachedValueBox {
            return Binding(
                get: { __detachedValueBox.wrappedValue },
                set: { __detachedValueBox.wrappedValue = $0 }
            )
        }
        
        switch storage {
            case .state(let state):
                return state.projectedValue
            case .binding(let binding):
                return binding
        }
    }

    @inlinable
    public init(_ value: Value) {
        self.initialValue = value
        self.storage = .state(State(initialValue: value))
    }
    
    @inlinable
    public init(_ binding: Binding<Value>) {
        self.initialValue = binding.wrappedValue
        self.storage = .binding(binding)
    }
    
    @inlinable
    public init(_ binding: Binding<Value>?, initialValue: Value) {
        self.initialValue = initialValue

        if let binding {
            self.storage = .binding(binding)
        } else {
            self.storage = .state(.init(initialValue: initialValue))
        }
    }
    
    @inlinable
    public init<T>(_ binding: Binding<T?>?) where Value == Optional<T> {
        if let binding {
            self.initialValue = binding.wrappedValue
            self.storage = .binding(binding)
        } else {
            self.initialValue = nil
            self.storage = .state(State(initialValue: Value.init(nilLiteral: ())))
        }
    }
}

// MARK: - Conformances

extension StateOrBinding: Equatable where Value: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension StateOrBinding: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        wrappedValue.hash(into: &hasher)
    }
}
