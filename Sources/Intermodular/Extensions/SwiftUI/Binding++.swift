//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension Binding {
    public func _unsafeMapGetter<Result>(_ transform: @escaping (Value) -> Result) -> Binding<Result> {
        .init(
            get: { transform(self.wrappedValue) },
            set: { _ in fatalError() }
        )
    }
    
    public func _unsafeForceCast<U>(to type: U.Type) -> Binding<U> {
        return .init(
            get: { self.wrappedValue as! U },
            set: { self.wrappedValue = $0 as! Value }
        )
    }

    public func withDefaultValue<T>(_ defaultValue: T) -> Binding<T> where Value == Optional<T> {
        return .init(
            get: { self.wrappedValue ?? defaultValue },
            set: { self.wrappedValue = $0 }
        )
    }
    
    public func prehookSetter(_ body: @escaping (Value) -> ()) -> Self {
        return .init(
            get: { self.wrappedValue },
            set: { body($0); self.wrappedValue = $0 }
        )
    }
    
    public func posthookSetter(_ body: @escaping (Value) -> ()) -> Self {
        return .init(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0; body($0) }
        )
    }
}
