//
// Copyright (c) Vatsal Manot
//

import CoreData
import Swift
import SwiftUI

/// A view that allows for inlined access to an `EnvironmentValues` key path.
public struct EnvironmentValueAccessView<Value, Content: View>: View {
    private let keyPath: KeyPath<EnvironmentValues, Value>
    private let content: (Value) -> Content
    
    @usableFromInline
    @Environment var environmentValue: Value
    
    public init(
        _ keyPath: KeyPath<EnvironmentValues, Value>,
        @ViewBuilder content: @escaping (Value) -> Content
    ) {
        self.keyPath = keyPath
        self.content = content
        
        self._environmentValue = .init(keyPath)
    }
    
    public var body: some View {
        content(environmentValue)
    }
}

extension Environment {
    public init<T>(_type: T.Type) where Value == Optional<T> {
        self.init(\EnvironmentValues.[_type: _SwiftUIX_Metatype<T.Type>(_type)])
    }
}

open class DefaultEnvironmentKey<Value>: EnvironmentKey {
    public static var defaultValue: Value? {
        nil
    }
}

extension View {
    @inlinable
    public func environment(_ newEnvironment: EnvironmentValues) -> some View {
        transformEnvironment(\.self) { environment in
            environment = newEnvironment
        }
    }
    
    @inlinable
    public func managedObjectContext(_ managedObjectContext: NSManagedObjectContext) -> some View {
        environment(\.managedObjectContext, managedObjectContext)
    }
}

extension View {
    public func _environment<T>(_ value: T?) -> some View {
        environment(\.[_type: _SwiftUIX_Metatype<T.Type>(T.self)], value)
    }
    
    public func _environment<T>(_ key: T.Type, _ value: T) -> some View {
        environment(\.[_type: _SwiftUIX_Metatype<T.Type>(key)], value)
    }
}

extension EnvironmentValues {
    @_spi(Internal)
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
}

public func withEnvironmentValue<T, Content: View>(
    _ keyPath: KeyPath<EnvironmentValues, T>,
    @ViewBuilder content: @escaping (T) -> Content
) -> EnvironmentValueAccessView<T, Content> {
    .init(keyPath, content: content)
}
