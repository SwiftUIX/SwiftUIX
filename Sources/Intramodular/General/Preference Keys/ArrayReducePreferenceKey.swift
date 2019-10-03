//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct ArrayReducePreferenceKey<Element>: PreferenceKey {
    public typealias Value = [Element]
    
    public static var defaultValue: Value {
        return []
    }
    
    public static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
}
