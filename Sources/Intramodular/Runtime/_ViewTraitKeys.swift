//
// Copyright (c) Vatsal Maot
//

import SwiftUI

/// An interface that exposes reading/writing view traits.
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

// MARK: - Deprecated

/// This will be deprecated soon.
public struct _ViewTraitKeys {
    public init() {
        
    }
}

extension View {
    public func _trait<TraitKey: _ViewTraitKey>(
        _ key: KeyPath<_ViewTraitKeys, TraitKey.Type>,
        _ value: TraitKey.Value
    ) -> some View {
        _trait(_ViewTraitKeys()[keyPath: key], value)
    }
}

extension _VariadicViewChildren.Subview {
    @dynamicMemberLookup
    @frozen
    public struct TraitsView {
        public var base: _VariadicViewChildren.Subview
        
        @_transparent
        public init(base: _VariadicViewChildren.Subview) {
            self.base = base
        }
        
        @inlinable
        public subscript<Key: _ViewTraitKey>(
            dynamicMember keyPath: KeyPath<_ViewTraitKeys, Key.Type>
        ) -> Key.Value {
            base[trait: keyPath]
        }

        @inlinable
        public subscript<Key: _ViewTraitKey>(
            dynamicMember keyPath: WritableKeyPath<_ViewTraitKeys, Key.Type>
        ) -> Key.Value {
            get {
                base[trait: keyPath]
            } set {
                base[trait: keyPath] = newValue
            }
        }
    }
    
    @_transparent
    public var traits: TraitsView {
        get {
            TraitsView(base: self)
        } set {
            self = newValue.base
        }
    }
}
