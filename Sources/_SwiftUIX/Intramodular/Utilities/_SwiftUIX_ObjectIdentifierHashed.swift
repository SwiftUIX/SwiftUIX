//
// Copyright (c) Vatsal Manot
//

import Swift

@propertyWrapper
@_documentation(visibility: internal)
public struct _SwiftUIX_ObjectIdentifierHashed<Wrapped>: Hashable {
    public let _hashImpl: (Wrapped, inout Hasher) -> Void
    public var wrappedValue: Wrapped
    
    public init(wrappedValue: Wrapped) where Wrapped: AnyObject {
        self.wrappedValue = wrappedValue
        self._hashImpl = { ObjectIdentifier($0).hash(into: &$1) }
    }
    
    public init<T: AnyObject>(wrappedValue: Wrapped) where Wrapped == Optional<T> {
        self.wrappedValue = wrappedValue
        self._hashImpl = { $0.map({ ObjectIdentifier($0) }).hash(into: &$1) }
    }
    
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        _hashImpl(wrappedValue, &hasher)
    }
}
