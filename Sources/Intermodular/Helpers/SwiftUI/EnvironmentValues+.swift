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

public func withEnvironmentValue<T, Content: View>(
    _ keyPath: KeyPath<EnvironmentValues, T>,
    @ViewBuilder content: @escaping (T) -> Content
) -> EnvironmentValueAccessView<T, Content> {
    .init(keyPath, content: content)
}
