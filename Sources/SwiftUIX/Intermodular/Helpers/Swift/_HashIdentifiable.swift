//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol _HashIdentifiable: Hashable, Identifiable where Self.ID == Int {
    
}

// MARK: - Implementation

extension _HashIdentifiable {
    @inlinable
    public var id: Int {
        hashValue
    }
}

// MARK: - API

extension Hashable {
    @inlinable
    package var hashIdentifiable: _HashIdentifiableValue<Self> {
        _HashIdentifiableValue(self)
    }
}

@frozen
@_documentation(visibility: internal)
public struct _HashIdentifiableValue<Value: Hashable>: CustomStringConvertible, _HashIdentifiable {
    public let value: Value
    
    public var description: String {
        String(describing: value)
    }
    
    @inlinable
    public init(_ value: Value) {
        self.value = value
    }
}

@frozen
@_documentation(visibility: internal)
public struct _KeyPathEquatable<Root, Value: Equatable>: Equatable {
    public let root: Root
    public let keyPath: KeyPath<Root, Value>
    
    public init(root: Root, keyPath: KeyPath<Root, Value>) {
        self.root = root
        self.keyPath = keyPath
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.keyPath == rhs.keyPath else {
            return false
        }
        
        return lhs.root[keyPath: lhs.keyPath] == rhs.root[keyPath: rhs.keyPath]
    }
}

@_documentation(visibility: internal)
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

@frozen
@_documentation(visibility: internal)
public struct _ArbitrarilyIdentifiedValue<Value, ID: Hashable>: CustomStringConvertible, Identifiable {
    public let value: Value
    public let _id: (Value) -> ID
    
    public var description: String {
        String(describing: value)
    }
    
    @_transparent
    public var id: ID {
        _id(value)
    }
    
    @_transparent
    public init(value: Value, id: @escaping (Value) -> ID) {
        self.value = value
        self._id = id
    }
    
    @_transparent
    public init(value: Value, id: ID) {
        self.value = value
        self._id = { _ in id }
    }
}

@frozen
@_documentation(visibility: internal)
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
