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
    
    @State private var objectContainer = _OptionalObservedObjectContainer<ObjectType>()
    
    @ObservedObject private var observedObjectContainer = _OptionalObservedObjectContainer<ObjectType>()
    
    public var wrappedValue: ObjectType {
        get {
            if let object = objectContainer.base {
                if observedObjectContainer.base !== object {
                    observedObjectContainer.base = object
                }
                
                return object
            } else {
                let object = thunk()
                
                objectContainer.base = object
                observedObjectContainer.base = object
                
                return object
            }
        } nonmutating set {
            objectContainer.base = newValue
            observedObjectContainer.base = newValue
        }
    }
    
    public var projectedValue: ObservedObject<ObjectType>.Wrapper {
        ObservedObject(wrappedValue: wrappedValue).projectedValue
    }
    
    public init(wrappedValue thunk: @autoclosure @escaping () -> ObjectType) {
        self.thunk = thunk
    }
    
    public mutating func update() {
        _objectContainer.update()
        _observedObjectContainer.update()
    }
}
