//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// Environment values and objects captured for insertion into view hierarchies.
@_documentation(visibility: internal)
public struct EnvironmentInsertions {
    var valuesByKeyPath: [PartialKeyPath<EnvironmentValues>: Any] = [:]
    var environmentValuesTransforms: [AnyHashable: (inout EnvironmentValues) -> Void] = [:]
    var environmentObjectTransforms: [AnyHashable: (AnyView) -> AnyView] = [:]
    var weakEnvironmentObjectTransforms: [AnyHashable: (AnyView) -> AnyView] = [:]

    public var _isOnlyEnvironmentValues: Bool {
        environmentObjectTransforms.isEmpty && weakEnvironmentObjectTransforms.isEmpty
    }
    
    public var isEmpty: Bool {
        valuesByKeyPath.isEmpty
            && self.environmentObjectTransforms.isEmpty
            && self.environmentValuesTransforms.isEmpty
            && weakEnvironmentObjectTransforms.isEmpty
    }

    public init() {
        
    }
}

extension EnvironmentInsertions {
    public subscript<Value>(_ keyPath: WritableKeyPath<EnvironmentValues, Value>) -> Value? {
        get {
            valuesByKeyPath[keyPath] as? Value
        } set {
            valuesByKeyPath[keyPath] = newValue
        }
    }

    public mutating func transformEnvironment(
        _ transform: @escaping (inout EnvironmentValues) -> Void,
        withKey key: AnyHashable
    ) {
        guard environmentValuesTransforms.index(forKey: key) == nil else {
            return
        }
        
        environmentValuesTransforms[key] = transform
    }
    
    public mutating func transformEnvironment<Key: Hashable>(
        _ transform: @escaping (inout EnvironmentValues) -> Void,
        withKey key: Key
    ) {
        transformEnvironment(transform, withKey: .init(key))
    }
    
    public mutating func transformEnvironment(_ transform: @escaping (inout EnvironmentValues) -> Void) {
        transformEnvironment(transform, withKey: UUID())
    }

    private mutating func insert<B: ObservableObject>(
        _ bindable: B,
        withKey key: AnyHashable
    ) {
        guard environmentObjectTransforms.index(forKey: key) == nil else {
            return
        }
        
        environmentObjectTransforms[key] = { $0.environmentObject(bindable).eraseToAnyView() }
    }
    
    public mutating func insert<B: ObservableObject>(_ bindable: B) {
        insert(bindable, withKey: ObjectIdentifier(bindable))
    }

    private mutating func insert<B: ObservableObject>(weak bindable: B, withKey key: AnyHashable) {
        guard weakEnvironmentObjectTransforms.index(forKey: key) == nil else {
            return
        }
        
        weakEnvironmentObjectTransforms[key] = { [weak bindable] in
            if let bindable = bindable {
                return $0.environmentObject(bindable).eraseToAnyView()
            } else {
                return $0.eraseToAnyView()
            }
        }
    }
            
    public mutating func insert<B: ObservableObject>(weak bindable: B) {
        insert(weak: bindable, withKey: ObjectIdentifier(bindable))
    }
}

extension EnvironmentInsertions {
    public mutating func merge(
        _ insertions: EnvironmentInsertions?
    ) {
        guard let insertions else {
            return
        }
        
        valuesByKeyPath.merge(
            insertions.valuesByKeyPath,
            uniquingKeysWith: { lhs, rhs in lhs }
        )
        environmentValuesTransforms.merge(
            insertions.environmentValuesTransforms,
            uniquingKeysWith: { lhs, rhs in lhs }
        )
        environmentObjectTransforms.merge(
            insertions.environmentObjectTransforms,
            uniquingKeysWith: { lhs, rhs in lhs }
        )
        weakEnvironmentObjectTransforms.merge(
            insertions.environmentObjectTransforms,
            uniquingKeysWith: { lhs, rhs in lhs }
        )
    }
}

// MARK: - Initializers

extension EnvironmentInsertions {
    public static func value<T>(
        _ value: T,
        forKey keyPath: WritableKeyPath<EnvironmentValues, T>
    ) -> EnvironmentInsertions {
        var result = Self()
        
        result.transformEnvironment {
            $0[keyPath: keyPath] = value
        }
        
        return result
    }
    
    public static func object<B: ObservableObject>(
        _ bindable: B
    ) -> Self {
        var result = Self()
        
        result.insert(bindable)
        
        return result
    }
    
    public static func weakObject<B: ObservableObject>(
        _ bindable: B
    ) -> Self {
        var result = Self()
        
        result.insert(weak: bindable)
        
        return result
    }
}

// MARK: - Supplementary

extension View {
    public func environment(
        _ insertions: EnvironmentInsertions
    ) -> some View {
        _insertEnvironment(insertions)
    }
    
    @ViewBuilder
    private func _insertEnvironment(
        _ insertions: EnvironmentInsertions
    ) -> some View {
        if insertions._isOnlyEnvironmentValues {
            self.transformEnvironment(\.self) { environment in
                insertions._apply(to: &environment)
            }
        } else {
            insertions
                .environmentObjectTransforms
                .values // FIXME: The order can change here.
                .reduce(eraseToAnyView(), { view, transform in transform(view) })
                .transformEnvironment(\.self) { environment in
                    insertions._apply(to: &environment)
                }
                .transformEnvironment(\._environmentInsertions) {
                    $0.merge(insertions)
                }
        }
    }
}

// MARK: - Auxiliary

extension EnvironmentInsertions {
    func _apply(to environment: inout EnvironmentValues) {
        valuesByKeyPath.forEach {
            try! ($0.key as! _opaque_WritableKeyPathType)._opaque_assign($0.value, to: &environment)
        }
        
        environmentValuesTransforms.values.forEach({ $0(&environment) })
    }
}

extension EnvironmentValues {
    struct EnvironmentInsertionsKey: EnvironmentKey {
        static let defaultValue = EnvironmentInsertions()
    }

    public var _environmentInsertions: EnvironmentInsertions {
        get {
            self[EnvironmentInsertionsKey.self]
        } set {
            self[EnvironmentInsertionsKey.self] = newValue
        }
    }
}

// MARK: - Helpers

fileprivate protocol _opaque_WritableKeyPathType {
    func _opaque_assign<_Value, _Root>(_ value: _Value, to root: inout _Root) throws
}

extension WritableKeyPath: _opaque_WritableKeyPathType {
    func _opaque_assign<_Value, _Root>(_ value: _Value, to root: inout _Root) throws {
        guard var _root = root as? Root, let value = value as? Value else {
            throw CastError.invalidTypeCast
        }
        
        _root[keyPath: self] = value
        
        root = _root as! _Root
    }
}

fileprivate enum CastError: Error {
    case invalidTypeCast
}
