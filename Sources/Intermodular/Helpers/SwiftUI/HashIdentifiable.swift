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

// MARK: - Helpers -

extension Hashable {
    @inlinable
    public var hashIdentifiable: HashIdentifiableValue<Self> {
        return .init(self)
    }
}

// MARK: - Concrete Implementations -

public struct HashIdentifiableValue<Value: Hashable>: HashIdentifiable {
    public let value: Value
    
    @inlinable
    public init(_ value: Value) {
        self.value = value
    }
}
