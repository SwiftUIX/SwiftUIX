//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A @State-like property wrapper that offers affordances for observing value changes as a stream of publisher events.
@propertyWrapper
public struct ObservableState<Value>: DynamicProperty {
    public typealias ValueChange = (oldValue: Value, newValue: Value)

    private var _willChange: PassthroughSubject<ValueChange, Never>
    private var _didChange: PassthroughSubject<ValueChange, Never>

    @State private var _wrappedValue: (previous: Value?, current: Value)

    public var willChange: AnyPublisher<ValueChange, Never> {
        return _willChange.eraseToAnyPublisher()
    }

    public var didChange: AnyPublisher<ValueChange, Never> {
        return _didChange.eraseToAnyPublisher()
    }

    public var wrappedValue: Value {
        get {
            _wrappedValue.current
        } nonmutating set {
            defer {
                _didChange.send((_wrappedValue.current, newValue))
            }

            _willChange.send((_wrappedValue.current, newValue))

            _wrappedValue = (_wrappedValue.current, newValue)
        }
    }

    public var binding: Binding<Value> {
        return .init(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0 }
        )
    }

    public init(wrappedValue value: Value) {
        self._willChange = .init()
        self._didChange = .init()
        self.__wrappedValue = .init(initialValue: (nil, value))
    }
}
