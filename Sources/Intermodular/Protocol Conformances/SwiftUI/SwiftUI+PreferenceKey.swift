//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

open class ArrayReducePreferenceKey<Element>: PreferenceKey {
    public typealias Value = [Element]
    
    public static var defaultValue: Value {
        return []
    }
    
    public static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
}

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
