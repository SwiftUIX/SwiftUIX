//
// Copyright (c) Vatsal Manot
//

import Swift

@propertyWrapper
class _SwiftUIX_ReferenceBox<T> {
    var value: T
    
    var wrappedValue: T {
        get {
            value
        } set {
            value = newValue
        }
    }
    
    init(value: T) {
        self.value = value
    }
    
    convenience init(wrappedValue: T) {
        self.init(value: wrappedValue)
    }
}
