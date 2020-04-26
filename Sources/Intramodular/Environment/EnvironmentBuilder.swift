//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// Builds an environment for a given view.
public struct EnvironmentBuilder {
    @usableFromInline
    var environmentValuesTransforms: [AnyHashable: (inout EnvironmentValues) -> Void] = [:]
    @usableFromInline
    var environmentObjectTransforms: [AnyHashable: (AnyView) -> AnyView] = [:]
    
    public var isEmpty: Bool {
        environmentObjectTransforms.isEmpty && environmentValuesTransforms.isEmpty
    }
    
    @inlinable
    public init() {
        
    }
}

extension EnvironmentBuilder {
    @inlinable
    public mutating func transformEnvironment(_ transform: @escaping (inout EnvironmentValues) -> Void, withKey key: AnyHashable) {
        guard environmentValuesTransforms.index(forKey: key) == nil else {
            return
        }
        
        environmentValuesTransforms[key] = transform
    }
    
    @inlinable
    public mutating func transformEnvironment<Key: Hashable>(_ transform: @escaping (inout EnvironmentValues) -> Void, withKey key: Key) {
        transformEnvironment(transform, withKey: .init(key))
    }
    
    @inlinable
    public mutating func transformEnvironment(_ transform: @escaping (inout EnvironmentValues) -> Void) {
        transformEnvironment(transform, withKey: UUID())
    }
    
    @inlinable
    public mutating func insert<B: ObservableObject>(_ bindable: B, withKey key: AnyHashable) {
        guard environmentObjectTransforms.index(forKey: key) == nil else {
            return
        }
        
        environmentObjectTransforms[key] = { $0.environmentObject(bindable).eraseToAnyView() }
    }
    
    @inlinable
    public mutating func insert<B: ObservableObject, Key: Hashable>(_ bindable: B, withKey key: Key) {
        insert(bindable, withKey: .init(key))
    }
    
    @inlinable
    public mutating func insert<B: ObservableObject>(_ bindable: B) {
        insert(bindable, withKey: ObjectIdentifier(bindable))
    }
    
    @inlinable
    public mutating func merge(_ builder: EnvironmentBuilder?) {
        guard let builder = builder else {
            return
        }
        
        environmentValuesTransforms.merge(builder.environmentValuesTransforms) { x, y in x }
        environmentObjectTransforms.merge(builder.environmentObjectTransforms) { x, y in x }
    }
}

// MARK: - API -

extension EnvironmentBuilder {
    public static func object<B: ObservableObject>(_ bindable: B) -> Self {
        var result = Self()
        
        result.insert(bindable)
        
        return result
    }
}

extension View {
    @inlinable
    public func mergeEnvironmentBuilder(_ builder: EnvironmentBuilder) -> some View {
        Group {
            if builder.isEmpty {
                self
            } else {
                _mergeEnvironmentBuilder(builder)
            }
        }
    }
    
    @inlinable
    public func _mergeEnvironmentBuilder(_ builder: EnvironmentBuilder) -> some View {
        var view = eraseToAnyView()
        
        view = builder.environmentObjectTransforms.values.reduce(view, { view, transform in transform(view) })
        
        return view.transformEnvironment(\.self) { environment in
            builder.environmentValuesTransforms.values.forEach({ $0(&environment) })
        }
        .transformEnvironment(\.environmentBuilder, transform: { $0.merge(builder) })
    }
}

// MARK: - Auxiliary Implementation -

extension EnvironmentBuilder {
    struct EnvironmentKey: SwiftUI.EnvironmentKey {
        static let defaultValue = EnvironmentBuilder()
    }
}

extension EnvironmentValues {
    public var environmentBuilder: EnvironmentBuilder {
        get {
            self[EnvironmentBuilder.EnvironmentKey]
        } set {
            self[EnvironmentBuilder.EnvironmentKey] = newValue
        }
    }
}
