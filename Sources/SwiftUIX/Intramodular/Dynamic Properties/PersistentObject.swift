//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A property wrapper type that instantiates an observable object.
@propertyWrapper
@_documentation(visibility: internal)
public struct PersistentObject<Value>: DynamicProperty {
    private let thunk: () -> AnyObject?
    
    @State private var objectContainer: _AnyObservableObjectMutableBox<Value>
    @State private var foo: Bool = false

    @ObservedObject package var observedObjectContainer: _AnyObservableObjectMutableBox<Value>
    
    public var wrappedValue: Value {
        get {
            _ = foo
            
            if objectContainer.__unsafe_opaque_base != nil {                
                return objectContainer.wrappedValue
            } else {
                return _thunkUnconditionally()
            }
        } nonmutating set {
            _ = foo
            
            observedObjectContainer._objectWillChange_send()

            objectContainer.__unsafe_opaque_base = newValue
            observedObjectContainer.__unsafe_opaque_base = objectContainer.__unsafe_opaque_base
            
            foo.toggle()
        }
    }
    
    public var projectedValue: Wrapper {
        PersistentObject.Wrapper(base: self)
    }

    public init(
        wrappedValue thunk: @autoclosure @escaping () -> Value
    ) where Value: ObservableObject {
        self.thunk = thunk
        self._objectContainer = State(initialValue: _ObservableObjectMutableBox(makeBase: thunk))
        self._observedObjectContainer = ObservedObject(initialValue: _ObservableObjectMutableBox(makeBase: thunk))
    }
    
    public init<T: ObservableObject>(
        wrappedValue thunk: @autoclosure @escaping () -> Value
    ) where Value == Optional<T> {
        self.thunk = { thunk() }
        self._objectContainer = State(initialValue: _ObservableObjectMutableBox(base: nil))
        self._observedObjectContainer = ObservedObject(initialValue: _ObservableObjectMutableBox(base: nil))
    }
    
    public init<T: ObservableObject & _SwiftUIX_MutablePropertyWrapperObject>(
        unwrapping thunk: @autoclosure @escaping () -> T
    ) where Value == T._SwiftUIX_WrappedValueType {
        self.thunk = { thunk() }
        
        let makeBox: (() -> _AnyObservableObjectMutableBox<T._SwiftUIX_WrappedValueType>) = {
            _ObservableObjectMutableBox<T, T._SwiftUIX_WrappedValueType>(
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
    ) where Value == T._SwiftUIX_WrappedValueType {
        self.init(unwrapping: thunk())
    }
    
    public mutating func update() {
        _objectContainer.update()
        _observedObjectContainer.update()
        
        if objectContainer.__unsafe_opaque_base == nil {
            _thunkUnconditionally()
        }
    }
    
    @discardableResult
    private func _thunkUnconditionally() -> Value {
        var isFirstThunk: Bool = false
        
        if objectContainer.__unsafe_opaque_base == nil {
            assert(observedObjectContainer.__unsafe_opaque_base == nil)
            
            isFirstThunk = true
        }
        
        let result: AnyObject? = thunk()
        
        objectContainer.__unsafe_opaque_base = result
        observedObjectContainer.__unsafe_opaque_base = result
        
        if isFirstThunk {
            Task.detached { @MainActor in
                foo.toggle()
            }
        }
        
        return observedObjectContainer.wrappedValue
    }
    
    public func _toggleFoo() {
        foo.toggle()
    }
}

extension PersistentObject {
    @dynamicMemberLookup
    public struct Wrapper {
        public let base: PersistentObject
        
        @MainActor
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
        
        @MainActor
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

extension PersistentObject: @unchecked Sendable where Value: Sendable {
    
}
