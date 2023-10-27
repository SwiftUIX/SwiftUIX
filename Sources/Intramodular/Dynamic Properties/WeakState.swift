//
// Copyright (c) Vatsal Manot
//

import SwiftUI

@propertyWrapper
public struct WeakState<Value: AnyObject>: DynamicProperty {
    @usableFromInline
    struct Storage {
        weak var wrappedValue: Value?
        
        @usableFromInline
        init(wrappedValue: Value?) {
            self.wrappedValue = wrappedValue
        }
    }
    
    @usableFromInline
    @State var storage: Storage
    
    public var wrappedValue: Value? {
        get {
            storage.wrappedValue
        } nonmutating set {
            if let oldValue = storage.wrappedValue, let newValue {
                guard newValue !== oldValue else {
                    return
                }
            }
            
            storage.wrappedValue = newValue
        }
    }
    
    public var projectedValue: Binding<Value?> {
        Binding<Value?>(
            get: {
                storage.wrappedValue
            },
            set: { newValue in
                storage.wrappedValue = newValue
            }
        )
    }
    
    public init(wrappedValue: Value?) {
        _storage = .init(initialValue: .init(wrappedValue: wrappedValue))
    }
}
