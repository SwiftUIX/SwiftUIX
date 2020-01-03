//
// Copyright (c) Vatsal Manot
//

import Dispatch
import Swift
import SwiftUI

@propertyWrapper
public struct OptionalEnvironmentObject<ObjectType: ObservableObject>: DynamicProperty {
    @EnvironmentObject private var _wrappedValue: ObjectType
    
    public var wrappedValue: ObjectType? {
        __wrappedValue.isPresent ? _wrappedValue : nil
    }
    
    public init() {
        
    }
    
    public mutating func update() {
        self.__wrappedValue.update()
    }
}
