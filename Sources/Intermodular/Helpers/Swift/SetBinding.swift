//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@propertyWrapper
public struct SetBinding<Value> {
    private let set: (Value) -> ()
    
    public init(set: @escaping (Value) -> ()) {
        self.set = set
    }
    
    public var wrappedValue: Value {
        get {
            fatalError()
        } nonmutating set {
            set(newValue)
        }
    }
    
    public var projectedValue: Binding<Value> {
        .init(
            get: { fatalError() },
            set: set
        )
    }
    
    public func set(_ value: Value) {
        self.set(value)
    }
}

// MARK: - Helpers -

extension Binding {
    public init(set: SetBinding<Value>, defaultValue: Value) {
        self.init(
            get: { defaultValue },
            set: { set.set($0) }
        )
    }
}
