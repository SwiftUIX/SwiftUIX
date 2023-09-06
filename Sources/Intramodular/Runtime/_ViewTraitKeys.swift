//
// Copyright (c) Vatsal Maot
//

import SwiftUI

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
    public struct TraitsView {
        public let base: _VariadicViewChildren.Subview
        
        public subscript<Key: _ViewTraitKey>(
            dynamicMember keyPath: KeyPath<_ViewTraitKeys, Key.Type>
        ) -> Key.Value {
            base[trait: keyPath]
        }
    }
    
    public var traits: TraitsView {
        .init(base: self)
    }
}
