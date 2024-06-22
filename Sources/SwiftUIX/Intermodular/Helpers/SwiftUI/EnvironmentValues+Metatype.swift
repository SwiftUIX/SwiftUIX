//
// Copyright (c) Vatsal Manot
//

import SwiftUI

extension View {
    @available(*, deprecated, message: "Please use View._environment(_:_:) instead.")
    public func _environment<T>(_ value: T?) -> some View {
        environment(\.[_type: _SwiftUIX_Metatype<T.Type>(T.self)], value)
    }
    
    public func _environment<T>(_ key: T.Type, _ value: T) -> some View {
        environment(\.[_type: _SwiftUIX_Metatype<T.Type>(key)], value)
    }
}

extension EnvironmentValues {
    public subscript<T>(
        _type type: _SwiftUIX_Metatype<T.Type>
    ) -> T? {
        get {
            self[DefaultEnvironmentKey<T>.self]
        } set {
            if let newValue {
                assert(Swift.type(of: newValue) == T.self)
            }
            
            self[DefaultEnvironmentKey<T>.self] = newValue
        }
    }
    
    public subscript<T>(
        _type type: _SwiftUIX_Metatype<T.Type>,
        default defaultValue: @autoclosure () -> T
    ) -> T {
        get {
            self[_type: type] ?? defaultValue()
        } set {
            self[_type: type] = newValue
        }
    }
}

extension Environment {
    @_disfavoredOverload
    public init<T>(
        _type: T.Type
    ) where Value == Optional<T> {
        self.init(\EnvironmentValues.[_type: _SwiftUIX_Metatype<T.Type>(_type)])
    }
    
    public init(
        _type: Value.Type
    ) where Value: ExpressibleByNilLiteral {
        let keyPath: KeyPath<EnvironmentValues, Value> = \EnvironmentValues.[_type: _SwiftUIX_Metatype<Value.Type>(_type)]._unwrappedDefaultingToNilLiteral
        
        self.init(keyPath)
    }
}

extension Optional where Wrapped: ExpressibleByNilLiteral {
    public var _unwrappedDefaultingToNilLiteral: Wrapped {
        self ?? Wrapped(nilLiteral: ())
    }
}
