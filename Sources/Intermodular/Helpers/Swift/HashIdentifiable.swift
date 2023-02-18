//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol HashIdentifiable: Hashable, Identifiable where Self.ID == Int {
    
}

// MARK: - Implementation

extension HashIdentifiable {
    @inlinable
    public var id: Int {
        hashValue
    }
}

// MARK: - API

extension Hashable {
    @inlinable
    public var hashIdentifiable: _HashIdentifiableValue<Self> {
        return .init(self)
    }
}

public struct _HashIdentifiableValue<Value: Hashable>: CustomStringConvertible, HashIdentifiable {
    public let value: Value
    
    public var description: String {
        .init(describing: value)
    }
    
    @inlinable
    public init(_ value: Value) {
        self.value = value
    }
}

public struct _KeyPathHashable<Root, Value: Hashable>: Hashable {
    public let root: Root
    public let keyPath: KeyPath<Root, Value>

    public init(_ root: Root, keyPath: KeyPath<Root, Value>) {
        self.root = root
        self.keyPath = keyPath
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(root[keyPath: keyPath])
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.root[keyPath: lhs.keyPath] == rhs.root[keyPath: rhs.keyPath]
    }
}

public struct _KeyPathHashIdentifiableValue<Value, ID: Hashable>: CustomStringConvertible, Identifiable {
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

extension _KeyPathHashIdentifiableValue: Equatable where Value: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value
    }
}

extension _KeyPathHashIdentifiableValue: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}
