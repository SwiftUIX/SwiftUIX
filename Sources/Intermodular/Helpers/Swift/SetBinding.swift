//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct SetBinding<Value> {
    private let setter: (Value) -> ()
    
    public init(setter: @escaping (Value) -> ()) {
        self.setter = setter
    }
    
    public var projectedValue: Binding<Value> {
        .init(
            get: { fatalError() },
            set: setter
        )
    }
    
    public func set(_ value: Value) {
        setter(value)
    }
    
}
