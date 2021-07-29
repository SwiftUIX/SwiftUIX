//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// Builds an environment for a given view.
public struct EnvironmentBuilder {
    @usableFromInline
    lazy var environmentValues: [AnyKeyPath: Any] = [:]
    @usableFromInline
    lazy var environmentValueKeyPaths: Set<KeyPath<EnvironmentValues, Any>> = []
    @usableFromInline
    lazy var environmentValuesTransforms: [AnyHashable: (inout EnvironmentValues) -> Void] = [:]
    
    @usableFromInline
    lazy var environmentObjects: [AnyHashable: AnyObject] = [:]
    @usableFromInline
    lazy var environmentObjectTransforms: [AnyHashable: (AnyView) -> AnyView] = [:]
    
    @inlinable
    public init() {
        
    }
}

extension EnvironmentBuilder {
    /// A Boolean value that indicates whether the builder is empty.
    public var isEmpty: Bool {
        var `self` = self
        
        return self.environmentObjectTransforms.isEmpty && self.environmentValuesTransforms.isEmpty
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
    
    public subscript<T>(_ keyPath: WritableKeyPath<EnvironmentValues, T>) -> T? {
        get {
            var `self` = self
            
            return self.environmentValues[keyPath] as? T
        } set {
            if let newValue = newValue {
                environmentValues[keyPath] = newValue
                environmentValuesTransforms[keyPath] = { $0[keyPath: keyPath] = newValue }
            } else {
                environmentValuesTransforms[keyPath] = nil
            }
        }
    }
}

extension EnvironmentBuilder {
    @inlinable
    public mutating func insert<B: ObservableObject>(_ bindable: B, withKey key: AnyHashable) {
        guard environmentObjectTransforms.index(forKey: key) == nil else {
            return
        }
        
        environmentObjects[key] = bindable
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
}

extension EnvironmentBuilder {
    @inlinable
    public mutating func merge(_ builder: EnvironmentBuilder?) {
        guard var builder = builder else {
            return
        }
        
        environmentValues.merge(builder.environmentValues, uniquingKeysWith: { x, y in x })
        environmentValuesTransforms.merge(builder.environmentValuesTransforms, uniquingKeysWith: { x, y in x })
        environmentObjects.merge(builder.environmentObjects, uniquingKeysWith: { x, y in x })
        environmentObjectTransforms.merge(builder.environmentObjectTransforms, uniquingKeysWith: { x, y in x })
    }
}

// MARK: - API -

extension EnvironmentBuilder {
    public static func value<T>(_ value: T, forKey key: WritableKeyPath<EnvironmentValues, T>) -> EnvironmentBuilder {
        var result = Self()
        
        result[key] = value
        
        return result
    }
    
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
    func _mergeEnvironmentBuilder(_ other: EnvironmentBuilder) -> some View {
        var other = other
        
        return other
            .environmentObjectTransforms
            .values
            .reduce(eraseToAnyView(), { view, transform in transform(view) })
            .transformEnvironment(\.self, transform: { environment in
                other.environmentValuesTransforms.values.forEach({ $0(&environment) })
            })
            .transformEnvironment(\.environmentBuilder, transform: {
                $0.merge(other)
            })
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
            self[EnvironmentBuilder.EnvironmentKey.self]
        } set {
            self[EnvironmentBuilder.EnvironmentKey.self] = newValue
        }
    }
}
