//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift
import SwiftUI

@propertyWrapper
public struct UserStorage<Value: Codable>: DynamicProperty {
    @Environment(\.errorContext) var errorContext
    
    private let key: String
    private let defaultValue: Value
    private let store: UserDefaults
    
    @PersistentObject private var valueBox = ObservableReferenceBox<Value?>(nil)
    
    public var wrappedValue: Value {
        get {
            valueBox.value ?? defaultValue
        } nonmutating set {
            valueBox.value = newValue
            
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
    }
    
    public mutating func update() {
        if valueBox.value == nil {
            do {
                valueBox.value = try store.decode(Value.self, forKey: key) ?? defaultValue
            } catch {
                errorContext.push(error)
                
                valueBox.value = defaultValue
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
