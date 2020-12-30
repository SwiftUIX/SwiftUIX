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

open class TakeFirstPreferenceKey<T>: PreferenceKey {
    public typealias Value = T?
    
    public static var defaultValue: Value {
        return nil
    }
    
    public static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value ?? nextValue()
    }
}

open class TakeLastPreferenceKey<T>: PreferenceKey {
    public typealias Value = T?
    
    public static var defaultValue: Value {
        return nil
    }
    
    public static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue() ?? value
    }
}
