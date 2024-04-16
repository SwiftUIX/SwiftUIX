//
// Copyright (c) Vatsal Manot
//

import SwiftUI

@frozen
public struct _VariadicViewChildren: View {
    @usableFromInline
    let base: SwiftUI._VariadicView.Children
    
    @usableFromInline
    @_optimize(speed)
    @_transparent
    init(erasing base: SwiftUI._VariadicView.Children) {
        self.base = base
    }
    
    @_optimize(speed)
    @_transparent
    public var body: some View {
        base
    }
}

extension _VariadicViewChildren: Identifiable {
    @frozen
    public struct ID: Hashable {
        @usableFromInline
        let base: SwiftUI._VariadicView.Children
        
        @_optimize(speed)
        @_transparent
        @usableFromInline
        init(base: SwiftUI._VariadicView.Children) {
            self.base = base
        }
        
        @_optimize(speed)
        @_transparent
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
    
    @_optimize(speed)
    @_transparent
    public var id: ID {
        ID(base: base)
    }
}

extension _VariadicViewChildren: RandomAccessCollection {
    public typealias Element = Subview
    public typealias Iterator = IndexingIterator<[_VariadicViewChildren.Subview]>
    public typealias Index = Int
    
    @_optimize(speed)
    @_transparent
    public func makeIterator() -> Iterator {
        base.map({ Subview($0) }).makeIterator()
    }
    
    @_optimize(speed)
    @_transparent
    public var startIndex: Index {
        base.startIndex
    }
    
    @_optimize(speed)
    @_transparent
    public var endIndex: Index {
        base.endIndex
    }
    
    @_optimize(speed)
    public subscript(position: Index) -> Element {
        Subview(base[position])
    }
    
    @_optimize(speed)
    @_transparent
    public func index(after index: Index) -> Index {
        base.index(after: index)
    }
}

extension _VariadicViewChildren {
    @frozen
    public struct Subview: View, Identifiable {
        @usableFromInline
        var element: SwiftUI._VariadicView.Children.Element
        
        @usableFromInline
        @_optimize(speed)
        @_transparent
        init(_ element: SwiftUI._VariadicView.Children.Element) {
            self.element = element
        }
        
        @_optimize(speed)
        @_transparent
        public var id: AnyHashable {
            element.id
        }
        
        @_optimize(speed)
        @_transparent
        public func id<ID: Hashable>(as _: ID.Type = ID.self) -> ID? {
            element.id(as: ID.self)
        }
        
        public subscript<Key: _ViewTraitKey>(
            key: Key.Type
        ) -> Key.Value {
            @_optimize(speed)
            @_transparent
            get {
                element[Key.self]
            }
            
            @_optimize(speed)
            @_transparent
            set {
                element[Key.self] = newValue
            }
        }
        
        public subscript<Key: _ViewTraitKey>(
            trait key: KeyPath<_ViewTraitKeys, Key.Type>
        ) -> Key.Value {
            @_optimize(speed)
            @_transparent
            get {
                element[_ViewTraitKeys()[keyPath: key]]
            }
            
            @_optimize(speed)
            @_transparent
            set {
                element[_ViewTraitKeys()[keyPath: key]] = newValue
            }
        }
        
        public subscript<Value>(_keyPath keyPath: KeyPath<Self, Value>) -> Value {
            @_optimize(speed)
            @_transparent
            get {
                self[keyPath: keyPath]
            }
        }
        
        @_optimize(speed)
        @_transparent
        public var body: some View {
            element
        }
    }
}

extension _VariadicViewChildren.Subview {
    @dynamicMemberLookup
    @frozen
    public struct TraitValues {
        @usableFromInline
        let base: _VariadicViewChildren.Subview
        
        @usableFromInline
        init(base: _VariadicViewChildren.Subview) {
            self.base = base
        }
        
        public subscript<Key: _ViewTraitKey>(
            dynamicMember keyPath: KeyPath<_ViewTraitKeys, Key.Type>
        ) -> Key.Value {
            @_transparent
            get {
                base[trait: keyPath]
            }
        }
    }
}

extension _VariadicViewChildren.Subview {
    public struct _ScrollElementID: Hashable {
        public let base: _VariadicViewChildren.Subview.ID
        
        public func hash(into hasher: inout Hasher) {
            base.hash(into: &hasher)
        }
    }
    
    public var _scrollElementID: _ScrollElementID {
        _ScrollElementID(base: self.id)
    }
}
