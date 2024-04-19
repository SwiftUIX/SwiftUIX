//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

@frozen
@propertyWrapper
public struct ViewStorage<Value>: DynamicProperty {
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
            
            super.init()
        }
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
