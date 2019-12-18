//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

open class TakeFirstPreferenceKey<T>: PreferenceKey {
    public typealias Value = T?
    
    public static var defaultValue: Value {
        return nil
    }
    
    public static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value ?? nextValue()
    }
}
