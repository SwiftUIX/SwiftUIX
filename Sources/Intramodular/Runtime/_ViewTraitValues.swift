//
// Copyright (c) Vatsal Maot
//

import SwiftUI

/// An interface that exposes reading/writing view traits.
///
/// This type is **WIP**.
public protocol _ViewTraitValuesStorage {
    subscript<Key: _ViewTraitKey>(_ key: Key.Type) -> Key.Value { get set }
}

extension _ViewTraitValuesStorage {
    public subscript<Key: _ViewTraitKey>(
        trait key: KeyPath<_ViewTraitKeys, Key.Type>
    ) -> Key.Value {
        get {
            self[_ViewTraitKeys()[keyPath: key]]
        } set {
            self[_ViewTraitKeys()[keyPath: key]] = newValue
        }
    }
}

/// An analogue to `EnvironmentValues`, but for view traits.
@frozen
public struct _ViewTraitValues {
    public var base: _ViewTraitValuesStorage
    
    public init(base: _ViewTraitValuesStorage) {
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

extension _VariadicViewChildren.Subview: _ViewTraitValuesStorage {
    
}
