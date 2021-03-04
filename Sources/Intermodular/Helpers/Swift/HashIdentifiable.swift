//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol HashIdentifiable: Hashable, Identifiable where Self.ID == Int {
    
}

// MARK: - Implementation -

extension HashIdentifiable {
    @inlinable
    public var id: Int {
        hashValue
    }
}

// MARK: - API -

extension Hashable {
    @inlinable
    public var hashIdentifiable: HashIdentifiableValue<Self> {
        return .init(self)
    }
}

public struct HashIdentifiableValue<Value: Hashable>: HashIdentifiable {
    public let value: Value
    
    @inlinable
    public init(_ value: Value) {
        self.value = value
    }
}

public struct KeyPathHashIdentifiableValue<Value, Identifier: Hashable>: Identifiable {
    public let value: Value
    public let keyPath: KeyPath<Value, Identifier>
    
    @inlinable
    public var id: HashIdentifiableValue<Identifier> {
        value[keyPath: keyPath].hashIdentifiable
    }
}
