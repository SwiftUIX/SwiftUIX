//
// Copyright (c) Vatsal Manot
//

import SwiftUI

/// An interface that exposes reading/writing view traits.
///
/// This type is **WIP**.
public protocol _ViewTraitValuesProtocol {
    subscript<Key: _ViewTraitKey>(_ key: Key.Type) -> Key.Value { get set }
}

extension _ViewTraitValuesProtocol {
    public subscript<Key: _ViewTraitKey>(
        trait key: KeyPath<_ViewTraitKeys, Key.Type>
    ) -> Key.Value {
        get {
            self[_ViewTraitKeys()[keyPath: key]]
        } set {
            self[_ViewTraitKeys()[keyPath: key]] = newValue
        }
    }
    
    public subscript<T>(
        trait: T.Type
    ) -> T? {
        get {
            self[_TypeToViewTraitKeyAdaptor<T>.self]
        } set {
            self[_TypeToViewTraitKeyAdaptor<T>.self] = newValue
        }
    }
}

/// An analogue to `EnvironmentValues`, but for view traits.
@frozen
@_documentation(visibility: internal)
public struct _ViewTraitValues {
    public var base: _ViewTraitValuesProtocol
    
    public init(base: _ViewTraitValuesProtocol) {
        self.base = base
    }
    
    @inlinable
    public subscript<Key: _ViewTraitKey>(_ key: Key.Type) -> Key.Value {
        get {
            base[key]
        } set {
            base[key] = newValue
        }
    }
}

extension _VariadicViewChildren.Subview: _ViewTraitValuesProtocol {
    
}
