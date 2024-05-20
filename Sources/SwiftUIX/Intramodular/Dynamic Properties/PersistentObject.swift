//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A property wrapper type that instantiates an observable object.
@propertyWrapper
public struct PersistentObject<Value>: DynamicProperty {
    private let thunk: () -> AnyObject?
    
    @State private var objectContainer: _AnyObservableObjectBox<Value>
    
    @ObservedObject private var observedObjectContainer: _AnyObservableObjectBox<Value>
    
    public var wrappedValue: Value {
        get {
            if let object = objectContainer.__unsafe_opaque_base {
                observedObjectContainer.__unsafe_opaque_base = object
                
                return objectContainer.wrappedValue
            } else {
                let object = thunk()
                
                objectContainer.__unsafe_opaque_base = object
                observedObjectContainer.__unsafe_opaque_base = object
                
                return objectContainer.wrappedValue
            }
        } nonmutating set {
            observedObjectContainer.objectWillChange.send()
            
            objectContainer.wrappedValue = newValue
            observedObjectContainer.wrappedValue = newValue
        }
    }
    
    public var projectedValue: Wrapper {
        PersistentObject.Wrapper(base: self)
    }

    public init(
        wrappedValue thunk: @autoclosure @escaping () -> Value
    ) where Value: ObservableObject {
        self.thunk = thunk
        self._objectContainer = State(initialValue: _ObservableObjectBox(makeBase: thunk))
        self._observedObjectContainer = ObservedObject(initialValue: _ObservableObjectBox(makeBase: thunk))
    }
    
    public init<T: ObservableObject>(
        wrappedValue thunk: @autoclosure @escaping () -> Value
    ) where Value == Optional<T> {
        self.thunk = { thunk() }
        self._objectContainer = State(initialValue: _ObservableObjectBox(base: nil))
        self._observedObjectContainer = ObservedObject(initialValue: _ObservableObjectBox(base: nil))
    }
    
    public init<T: ObservableObject & _SwiftUIX_MutablePropertyWrapperObject>(
        unwrapping thunk: @autoclosure @escaping () -> T
    ) where Value: ObservableObject, Value == T._SwiftUIX_WrappedValueType {
        self.thunk = { thunk() }
        
        let makeBox: (() -> _AnyObservableObjectBox<T._SwiftUIX_WrappedValueType>) = {
            _ObservableObjectBox<T, T._SwiftUIX_WrappedValueType>(
                base: nil,
                wrappedValue: { (propertyWrapper: inout T?) in
                    let _propertyWrapper: T
                    
                    if let propertyWrapper {
                        _propertyWrapper = propertyWrapper
                    } else {
                        _propertyWrapper = thunk()
                    }
                    
                    return Binding<Value>(
                        get: { [unowned _propertyWrapper] in
                            _propertyWrapper.wrappedValue
                        },
                        set: { [unowned _propertyWrapper] newValue in
                            _propertyWrapper.wrappedValue = newValue
                        }
                    )
                }
            )
        }
        self._objectContainer = State(initialValue: makeBox())
        self._observedObjectContainer = ObservedObject(initialValue: makeBox())
    }
    
    public init<T: ObservableObject & _SwiftUIX_MutablePropertyWrapperObject>(
        unwrapping thunk: @escaping () -> T
    ) where Value: ObservableObject, Value == T._SwiftUIX_WrappedValueType {
        self.init(unwrapping: thunk())
    }
    
    public mutating func update() {
        _objectContainer.update()
        _observedObjectContainer.update()
    }
}

extension PersistentObject {
    @dynamicMemberLookup
    public struct Wrapper {
        public let base: PersistentObject
        
        public var binding: Binding<Value> {
            Binding<Value>(
                get: {
                    base.wrappedValue
                },
                set: { newValue in
                    base.wrappedValue = newValue
                }
            )
        }
        
        public subscript<T>(
            dynamicMember keyPath: ReferenceWritableKeyPath<Value, T>
        ) -> Binding<T> {
            Binding<T>(
                get: {
                    base.wrappedValue[keyPath: keyPath]
                },
                set: { newValue in
                    base.wrappedValue[keyPath: keyPath] = newValue
                }
            )
        }
    }
}
