//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension Binding {
    @inlinable
    public func map<T>(_ keyPath: WritableKeyPath<Value, T>) -> Binding<T> {
        .init(
            get: { self.wrappedValue[keyPath: keyPath] },
            set: { self.wrappedValue[keyPath: keyPath] = $0 }
        )
    }
}

extension Binding {
    @inlinable
    public func beforeSet(_ body: @escaping (Value) -> ()) -> Self {
        return .init(
            get: { self.wrappedValue },
            set: { body($0); self.wrappedValue = $0 }
        )
    }
    
    @inlinable
    public func onSet(_ body: @escaping (Value) -> ()) -> Self {
        return .init(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0; body($0) }
        )
    }
    
    @inlinable
    public func onChange(perform action: @escaping (Value) -> ()) -> Self {
        return .init(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0; action($0) }
        )
    }
    
    @inlinable
    public func onChange(toggle value: Binding<Bool>) -> Self {
        onChange { _ in
            value.wrappedValue.toggle()
        }
    }
}

extension Binding {
    @inlinable
    public func forceCast<U>(to type: U.Type) -> Binding<U> {
        return .init(
            get: { self.wrappedValue as! U },
            set: { self.wrappedValue = $0 as! Value }
        )
    }
    
    @inlinable
    public func withDefaultValue<T>(_ defaultValue: T) -> Binding<T> where Value == Optional<T> {
        return .init(
            get: { self.wrappedValue ?? defaultValue },
            set: { self.wrappedValue = $0 }
        )
    }
    
    @inlinable
    public func isNil<Wrapped>() -> Binding<Bool> where Optional<Wrapped> == Value {
        .init(
            get: { self.wrappedValue == nil },
            set: { isNil in self.wrappedValue = isNil ? nil : self.wrappedValue  }
        )
    }
    
    @inlinable
    public func isNotNil<Wrapped>() -> Binding<Bool> where Optional<Wrapped> == Value {
        .init(
            get: { self.wrappedValue != nil },
            set: { isNotNil in self.wrappedValue = isNotNil ? self.wrappedValue : nil  }
        )
    }
    
    public func nilIfEmpty<T: Collection>() -> Binding where Value == Optional<T> {
        Binding(
            get: {
                guard let wrappedValue = self.wrappedValue, !wrappedValue.isEmpty else {
                    return nil
                }
                
                return wrappedValue
            },
            set: { newValue in
                if let newValue = newValue {
                    self.wrappedValue = newValue.isEmpty ? nil : newValue
                } else {
                    self.wrappedValue = nil
                }
            }
        )
    }
}

extension Binding where Value == Bool {
    @inlinable
    public static func && (lhs: Binding, rhs: Bool) -> Binding {
        .init(
            get: { lhs.wrappedValue && rhs },
            set: { lhs.wrappedValue = $0 }
        )
    }
}

extension Binding where Value == Bool? {
    @inlinable
    public static func && (lhs: Binding, rhs: Bool) -> Binding {
        .init(
            get: { lhs.wrappedValue.map({ $0 && rhs }) },
            set: { lhs.wrappedValue = $0 }
        )
    }
}

extension Binding where Value == String {
    @inlinable
    public func takePrefix(_ count: Int) -> Self {
        .init(
            get: { self.wrappedValue },
            set: {
                self.wrappedValue = $0
                self.wrappedValue = .init($0.prefix(count))
            }
        )
    }
    
    @inlinable
    public func takeSuffix(_ count: Int) -> Self {
        .init(
            get: { self.wrappedValue },
            set: {
                self.wrappedValue = $0
                self.wrappedValue = .init($0.suffix(count))
            }
        )
    }
}

extension Binding where Value == String? {
    @inlinable
    public func takePrefix(_ count: Int) -> Self {
        .init(
            get: { self.wrappedValue },
            set: {
                self.wrappedValue = $0
                self.wrappedValue = $0.map({ .init($0.prefix(count)) })
            }
        )
    }
    
    @inlinable
    public func takeSuffix(_ count: Int) -> Self {
        .init(
            get: { self.wrappedValue },
            set: {
                self.wrappedValue = $0
                self.wrappedValue = $0.map({ .init($0.suffix(count)) })
            }
        )
    }
}
