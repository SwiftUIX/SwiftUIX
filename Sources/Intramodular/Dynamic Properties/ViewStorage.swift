//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0,  *)
@propertyWrapper
public struct ViewStorage<Value>: DynamicProperty {
    final class ValueBox: ObservableObject {
        let objectWillChange = Empty<Never, Never>(completeImmediately: false)
        
        var value: Value
        
        init(_ value: Value) {
            self.value = value
        }
    }
    
    @StateObject private var valueBox: ValueBox
    
    public var wrappedValue: Value {
        get {
            valueBox.value
        } nonmutating set {
            valueBox.value = newValue
        }
    }
    
    public init(wrappedValue thunk: @autoclosure @escaping () -> Value) {
        self._valueBox = StateObject(wrappedValue: .init(thunk()))
    }
}
