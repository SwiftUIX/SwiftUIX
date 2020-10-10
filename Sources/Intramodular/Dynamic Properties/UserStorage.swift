//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift
import SwiftUI

@propertyWrapper
public struct UserStorage<Value: Codable>: DynamicProperty {
    private let key: String
    private let defaultValue: Value
    private let store: UserDefaults
    
    @State private var hasBeenInitialized = ReferenceBox(false)
    @State private var state: Value
    
    public var wrappedValue: Value {
        get {
            state
        } nonmutating set {
            state = newValue
            
            do {
                try store.encode(newValue, forKey: key)
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
    }
    /// The binding value, as "unwrapped" by accessing `$foo` on a `@Binding` property.
    public var projectedValue: Binding<Value> {
        return .init(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0 }
        )
    }
    
    public init(
        wrappedValue: Value,
        _ key: String,
        store: UserDefaults = .standard
    ) {
        self.defaultValue = wrappedValue
        self.key = key
        self.store = store
        
        self._state = .init(initialValue: wrappedValue)
    }
    
    public mutating func update() {
        if !hasBeenInitialized.value {
            do {
                _state = .init(initialValue: try store.decode(Value.self, forKey: key) ?? defaultValue)
                
                hasBeenInitialized.value = true
            } catch {
                assertionFailure()
            }
        }
    }
}

extension UserStorage where Value: ExpressibleByNilLiteral {
    public init(
        _ key: String,
        store: UserDefaults = .standard
    ) {
        self.init(wrappedValue: nil, key, store: store)
    }
}
