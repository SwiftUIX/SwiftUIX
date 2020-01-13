//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct KeyPathHashIdentifiableValue<Value, Identifier: Hashable>: Identifiable {
    public let value: Value
    public let keyPath: KeyPath<Value, Identifier>
    
    public var id: HashIdentifiableValue<Identifier> {
        value[keyPath: keyPath].hashIdentifiable
    }
}
