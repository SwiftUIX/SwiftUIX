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

public struct HashIdentifiableValue<Value: Hashable>: CustomStringConvertible, HashIdentifiable {
    public let value: Value
    
    public var description: String {
        .init(describing: value)
    }
    
    @inlinable
    public init(_ value: Value) {
        self.value = value
    }
}

public struct KeyPathHashIdentifiableValue<Value, ID: Hashable>: CustomStringConvertible, Identifiable {
    public let value: Value
    public let keyPath: KeyPath<Value, ID>
    
    public var description: String {
        .init(describing: value)
    }
    
    public var id: ID {
        value[keyPath: keyPath]
    }
    
    public init(value: Value, keyPath: KeyPath<Value, ID>) {
        self.value = value
        self.keyPath = keyPath
    }
}

extension KeyPathHashIdentifiableValue: Equatable where Value: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value
    }
}

extension KeyPathHashIdentifiableValue: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}
