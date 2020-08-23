//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct PersistentObject<ObjectType: ObservableObject>: DynamicProperty {
    let thunk: () -> ObjectType
    
    @OptionalObservedObject
    private var observedObject: ObjectType?
    @State
    public var state: ObjectType?
    
    public var wrappedValue: ObjectType {
        get {
            state!
        } nonmutating set {
            state = newValue
        }
    }
    public var projectedValue: ObservedObject<ObjectType>.Wrapper {
        ObservedObject(wrappedValue: observedObject!).projectedValue
    }
    
    public init(wrappedValue thunk: @autoclosure @escaping () -> ObjectType) {
        self.thunk = thunk
    }
    
    public mutating func update() {
        if _state.wrappedValue == nil {
            let object = thunk()
            
            _state = .init(initialValue: object)
            _observedObject = .init(wrappedValue: object)
        } else {
            observedObject = state
        }
    }
}
