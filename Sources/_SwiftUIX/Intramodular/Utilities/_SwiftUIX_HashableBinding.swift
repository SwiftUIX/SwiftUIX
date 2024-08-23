//
// Copyright (c) Vatsal Manot
//

import SwiftUI

@propertyWrapper
@_documentation(visibility: internal)
public struct _SwiftUIX_HashableBinding<Wrapped: Hashable>: DynamicProperty, Hashable {
    public var wrappedValue: Binding<Wrapped>
    
    public init(wrappedValue: Binding<Wrapped>) {
        self.wrappedValue = wrappedValue
    }
    
    public init(
        get: @escaping @Sendable () -> Wrapped,
        set: @escaping @Sendable (Wrapped) -> Void
    ) {
        self.wrappedValue = Binding(get: get, set: set)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.wrappedValue.wrappedValue == rhs.wrappedValue.wrappedValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue.wrappedValue)
    }
    
    @propertyWrapper
    public struct Optional: DynamicProperty, Hashable {
        public var wrappedValue: Binding<Wrapped>?
        
        public init(wrappedValue: Binding<Wrapped>?) {
            self.wrappedValue = wrappedValue
        }
        
        public init(
            get: @escaping @Sendable () -> Wrapped,
            set: @escaping @Sendable (Wrapped) -> Void
        ) {
            self.wrappedValue = Binding(get: get, set: set)
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.wrappedValue?.wrappedValue == rhs.wrappedValue?.wrappedValue
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(wrappedValue?.wrappedValue)
        }
    }
}
