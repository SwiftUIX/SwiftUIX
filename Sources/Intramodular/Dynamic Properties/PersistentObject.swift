//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A property wrapper type that instantiates an observable object.
@propertyWrapper
public struct PersistentObject<ObjectType: ObservableObject>: DynamicProperty {
    private let thunk: () -> ObjectType
    
    @OptionalObservedObject
    private var observedObject: ObjectType?
    @State
    private var state = ReferenceBox<ObjectType?>(nil)
    
    public var wrappedValue: ObjectType {
        get {
            if state.value == nil {
                state.value = thunk()
            }
            
            return state.value!
        } nonmutating set {
            state.value = newValue
            observedObject = newValue
        }
    }
    
    public var projectedValue: ObservedObject<ObjectType>.Wrapper {
        ObservedObject(wrappedValue: observedObject!).projectedValue
    }
    
    public init(wrappedValue thunk: @autoclosure @escaping () -> ObjectType) {
        self.thunk = thunk
    }
    
    public mutating func update() {
        if state.value == nil {
            let object = thunk()
            
            state.value = object
            observedObject = object
        }
    }
}
