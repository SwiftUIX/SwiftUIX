//
// Copyright (c) Vatsal Manot
//

import SwiftUI

@frozen
public struct _VariadicViewChildren: View {
    @usableFromInline
    let base: _VariadicView.Children
    
    @usableFromInline
    @_transparent
    init(erasing base: _VariadicView.Children) {
        self.base = base
    }
    
    @_transparent
    public var body: some View {
        base
    }
}

extension _VariadicViewChildren: Identifiable {
    public struct ID: Hashable {
        fileprivate let base: _VariadicView.Children
        
        public var _parent: _VariadicViewChildren {
            _VariadicViewChildren(erasing: base)
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.base.lazy.map(\.id) == rhs.base.lazy.map(\.id)
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(base.lazy.map(\.id))
        }
    }
    
    public var id: ID {
        ID(base: base)
    }
}

extension _VariadicViewChildren: RandomAccessCollection {
    public typealias Element = Subview
    public typealias Iterator = LazyMapSequence<LazySequence<_VariadicView.Children>.Elements, Element>.Iterator
    public typealias Index = Int
    
    public func makeIterator() -> Iterator {
        base.lazy.map({ Subview($0) }).makeIterator()
    }
    
    public var startIndex: Index {
        base.startIndex
    }
    
    public var endIndex: Index {
        base.endIndex
    }
    
    public subscript(position: Index) -> Element {
        Subview(base[position])
    }
    
    public func index(after index: Index) -> Index {
        base.index(after: index)
    }
}

extension _VariadicViewChildren {
    @frozen
    public struct Subview: View, Identifiable {
        @usableFromInline
        var element: _VariadicView.Children.Element
        
        init(_ element: _VariadicView.Children.Element) {
            self.element = element
        }
        
        public var id: AnyHashable {
            element.id
        }
        
        public func id<ID: Hashable>(as _: ID.Type = ID.self) -> ID? {
            element.id(as: ID.self)
        }
        
        public subscript<Key: _ViewTraitKey>(
            key: Key.Type
        ) -> Key.Value {
            get {
                element[Key.self]
            } set {
                element[Key.self] = newValue
            }
        }
        
        public subscript<Key: _ViewTraitKey>(
            trait key: KeyPath<_ViewTraitKeys, Key.Type>
        ) -> Key.Value {
            get {
                element[_ViewTraitKeys()[keyPath: key]]
            } set {
                element[_ViewTraitKeys()[keyPath: key]] = newValue
            }
        }
        
        public subscript<Value>(_keyPath keyPath: KeyPath<Self, Value>) -> Value {
            self[keyPath: keyPath]
        }
        
        public var body: some View {
            element
        }
    }
}

extension _VariadicViewChildren.Subview {
    @dynamicMemberLookup
    public struct TraitValues {
        private let base: _VariadicViewChildren.Subview
        
        init(base: _VariadicViewChildren.Subview) {
            self.base = base
        }
        public subscript<Key: _ViewTraitKey>(
            dynamicMember keyPath: KeyPath<_ViewTraitKeys, Key.Type>
        ) -> Key.Value {
            base[trait: keyPath]
        }
    }
}
