//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// The property wrapper can be used to add non-observable state capabilities to a view property.
///
/// `@ViewStorage` works just like `@State`, except modifying a `@ViewStorage` wrapped value does not cause the view's body to update.
///
/// You can read more about how to use this property wrapper in the <doc:SwiftUI-View-Storage> article.
@frozen
@propertyWrapper
public struct ViewStorage<Value>: Identifiable, DynamicProperty {
    public final class ValueBox: AnyObservableValue<Value> {
        @Published fileprivate var value: Value
        
        public override var wrappedValue: Value {
            get {
                value
            } set {
                value = newValue
            }
        }
        
        fileprivate init(_ value: Value) {
            self.value = value
            
            super.init(configuration: AnyObservableValue.Configuration())
        }
    }
    
    public var id: ObjectIdentifier {
        ObjectIdentifier(valueBox)
    }
    
    @State fileprivate var _valueBox: ValueBox
    
    public var wrappedValue: Value {
        get {
            _valueBox.value
        } nonmutating set {
            _valueBox.value = newValue
        }
    }
    
    public var projectedValue: ViewStorage<Value> {
        self
    }
    
    public var valueBox: ValueBox {
        _valueBox
    }
    
    public init(wrappedValue value: @autoclosure @escaping () -> Value) {
        self.__valueBox = .init(wrappedValue: ValueBox(value()))
    }
}

// MARK: - Conformances

extension ViewStorage: Equatable where Value: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension ViewStorage: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        wrappedValue.hash(into: &hasher)
    }
}

// MARK: - API

extension ViewStorage {
    public var binding: Binding<Value> {
        .init(
            get: { self.valueBox.value },
            set: { self.valueBox.value = $0 }
        )
    }
    
    public var publisher: Published<Value>.Publisher {
        valueBox.$value
    }
}

@MainActor
extension ViewStorage {
    @ViewBuilder
    public func withObservedValue<Content: View>(
        @ViewBuilder _ value: @escaping (Value) -> Content
    ) -> some View {
        withInlineObservedObject(_valueBox) {
            value($0.value)
        }
    }
}

extension ObservedValue {
    public init(_ storage: ViewStorage<Value>) {
        self.init(base: storage.valueBox)
    }
}
