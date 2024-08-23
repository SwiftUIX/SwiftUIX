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

@propertyWrapper
@_documentation(visibility: internal)
public final class _SwiftUIX_UnsafeSendableReferenceBox<T>: @unchecked Sendable {
    public var wrappedValue: T
    
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
}
