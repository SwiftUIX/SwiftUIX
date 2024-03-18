//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A property wrapper type that instantiates an observable object.
@propertyWrapper
public struct PersistentObject<Value>: DynamicProperty {
    private let thunk: () -> Value
    
    @State private var objectContainer: _ObservableObjectBox<Value>
    
    @ObservedObject private var observedObjectContainer: _ObservableObjectBox<Value>
    
    public var wrappedValue: Value {
        get {
            if let object = objectContainer.base {
                observedObjectContainer.base = object
                
                return object
            } else {
                let object = thunk()
                
                objectContainer.base = object
                observedObjectContainer.base = object
                
                return object
            }
        } nonmutating set {
            observedObjectContainer.objectWillChange.send()

            objectContainer.base = newValue
            observedObjectContainer.base = newValue
        }
    }
    
    public init(
        wrappedValue thunk: @autoclosure @escaping () -> Value
    ) where Value: ObservableObject {
        self.thunk = thunk
        self._objectContainer = .init(initialValue: .init(base: nil))
        self._observedObjectContainer = .init(initialValue: .init(base: nil))
    }
    
    public init<T: ObservableObject>(
        wrappedValue thunk: @autoclosure @escaping () -> Value
    ) where Value == Optional<T> {
        self.thunk = thunk
        self._objectContainer = .init(initialValue: .init(base: nil))
        self._observedObjectContainer = .init(initialValue: .init(base: nil))
    }
    
    public mutating func update() {
        _objectContainer.update()
        _observedObjectContainer.update()
    }
}

extension PersistentObject where Value: ObservableObject {
    public var projectedValue: ObservedObject<Value>.Wrapper {
        ObservedObject(wrappedValue: wrappedValue).projectedValue
    }
}
