//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift
import SwiftUI

@propertyWrapper
public struct UserDefaultsState<Value: Codable>: DynamicProperty {
    private let key: String
    private let defaultValue: Value
    private let defaults: UserDefaults
    
    @State private var _wrappedValue: Value
    
    public var wrappedValue: Value {
        get {
            _wrappedValue
        } nonmutating set {
            _wrappedValue = newValue
            
            try! defaults.encode(wrappedValue, forKey: key)
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
        _ key: String,
        defaultValue: Value,
        defaults: UserDefaults = .standard
    ) {
        self.key = key
        self.defaultValue = defaultValue
        self.defaults = defaults
        
        __wrappedValue = .init(initialValue: try! defaults.decode(forKey: key, defaultValue: defaultValue))
    }
    
    public mutating func update() {
        try! _wrappedValue = defaults.decode(forKey: key, defaultValue: defaultValue)
    }
}
