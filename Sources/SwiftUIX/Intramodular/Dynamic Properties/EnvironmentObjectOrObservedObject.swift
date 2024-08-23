//
// Copyright (c) Vatsal Manot
//

import Combine
import Dispatch
import Swift
import SwiftUI

/// A property wrapper type for an observable object supplied by a parent or ancestor view, either directly or via `View/environmentObject(_:)`.
@available(*, deprecated)
@propertyWrapper
@_documentation(visibility: internal)
public struct EnvironmentObjectOrObservedObject<Value: ObservableObject>: DynamicProperty {
    let defaultValue: () -> Value
    
    @EnvironmentObject.Optional private var _wrappedValue0: Value?
    
    @OptionalObservedObject private var _wrappedValue1: Value?
    
    public var wrappedValue: Value {
        if let result = _wrappedValue1 ?? _wrappedValue0 {
            return result
        } else {
            assertionFailure()
            
            return defaultValue()
        }
    }
    
    /// Initialize with the provided initial value.
    public init(defaultValue: @autoclosure @escaping () -> Value) {
        self.defaultValue = defaultValue
    }
    
    public mutating func update() {
        if _wrappedValue0 == nil {
            __wrappedValue1 = .init(wrappedValue: defaultValue())
        }
        
        self.__wrappedValue0.update()
        self.__wrappedValue1.update()
    }
}
