//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

@_documentation(visibility: internal)
open class ArrayReducePreferenceKey<Element>: PreferenceKey {
    public typealias Value = [Element]
    
    public static var defaultValue: Value {
        return []
    }
    
    public static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
}

@_documentation(visibility: internal)
open class TakeFirstPreferenceKey<T: Equatable>: PreferenceKey {
    public typealias Value = T?
    
    public static var defaultValue: Value {
        return nil
    }
    
    public static func reduce(value: inout Value, nextValue: () -> Value) {
        let newValue = value ?? nextValue()
        
        if value != newValue {
            value = newValue
        }
    }
}

@_documentation(visibility: internal)
open class TakeLastPreferenceKey<T: Equatable>: PreferenceKey {
    public typealias Value = T?
    
    public static var defaultValue: Value {
        return nil
    }
    
    public static func reduce(value: inout Value, nextValue: () -> Value) {
        let newValue = nextValue() ?? value
        
        if value != newValue {
            value = newValue
        }
    }
}
