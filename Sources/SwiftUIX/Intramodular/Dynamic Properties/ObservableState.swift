//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A @State-like property wrapper that offers affordances for observing value changes as a stream of publisher events.
@propertyWrapper
@_documentation(visibility: internal)
public struct ObservableState<Value>: DynamicProperty {
    @State private var base: ObservableValues.Root<Value>
    @ObservedObject private var observedBase: ObservableValues.Root<Value>
    
    /// An observable stream of value changes, before they happen.
    public var willChange: AnyPublisher<Void, Never> {
        base.objectWillChange.eraseToAnyPublisher()
    }
    
    /// An observable stream of value changes, after they happen.
    public var didChange: AnyPublisher<Void, Never> {
        base.objectDidChange.eraseToAnyPublisher()
    }
    
    /// The current state value.
    public var wrappedValue: Value {
        get {
            base.wrappedValue
        } nonmutating set {
            base.wrappedValue = newValue
        }
    }
    
    /// The binding value, as "unwrapped" by accessing `$foo` on a `@Binding` property.
    public var projectedValue: Wrapper {
        Wrapper(base: $base.map(\.wrappedValue))
    }
    
    /// Initialize with the provided initial value.
    public init(wrappedValue value: Value) {
        self._base = .init(wrappedValue: .init(root: value))
        self.observedBase = _base.wrappedValue
    }
    
    public mutating func update() {
        self.observedBase = base
    }
}

extension ObservableState {
    @dynamicMemberLookup
    public struct Wrapper {
        @Binding var base: Value
        
        public var binding: Binding<Value> {
            $base
        }
        
        public subscript<T>(
            dynamicMember keyPath: ReferenceWritableKeyPath<Value, T>
        ) -> Binding<T> {
            get {
                $base.map(keyPath)
            }
        }

        public subscript<T>(
            dynamicMember keyPath: ReferenceWritableKeyPath<Value, T>
        ) -> ObservedValue<T> where Value: ObservableObject {
            get {
                ObservedValue(keyPath, on: base)
            }
        }
    }
}
