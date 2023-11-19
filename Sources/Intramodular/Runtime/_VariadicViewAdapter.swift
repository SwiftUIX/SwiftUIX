//
// Copyright (c) Vatsal Manot
//

import SwiftUI

@frozen
public struct _VariadicViewAdapter<Source: View, Content: View>: View {
    @frozen
    @usableFromInline
    struct Root: _VariadicView.MultiViewRoot {
        @usableFromInline
        var content: (_TypedVariadicView<Source>) -> Content
        
        @usableFromInline
        @_transparent
        init(content: @escaping (_TypedVariadicView<Source>) -> Content) {
            self.content = content
        }
        
        @_transparent
        @usableFromInline
        func body(children: _VariadicView.Children) -> some View {
            content(_TypedVariadicView(children))
        }
    }
    
    @usableFromInline
    let source: Source
    @usableFromInline
    let content: (_TypedVariadicView<Source>) -> Content
    
    @_transparent
    public init(
        _ source: Source,
        @ViewBuilder content: @escaping (_TypedVariadicView<Source>) -> Content
    ) {
        self.source = source
        self.content = content
    }
    
    @_transparent
    public init(
        @ViewBuilder _ source: () -> Source,
        @ViewBuilder content: @escaping (_TypedVariadicView<Source>) -> Content
    ) {
        self.init(source(), content: content)
    }
    
    public init<Subview: View>(
        enumerating source: Source,
        @ViewBuilder subview: @escaping (Int, _VariadicViewChildren.Subview) -> Subview
    ) where Content == _ForEachSubview<Source, AnyHashable, Subview> {
        self.init(source) { content in
            _ForEachSubview(enumerating: content, enumerating: subview)
        }
    }
    
    @_transparent
    public var body: some View {
        _VariadicView.Tree(Root(content: content)) {
            source
        }
    }
}

@frozen
public struct _TypedVariadicView<Content: View>: View {
    public var children: _VariadicViewChildren
    
    @_transparent
    public var isEmpty: Bool {
        children.isEmpty
    }
    
    @usableFromInline
    @_transparent
    init(_ children: _VariadicView.Children) {
        self.children = _VariadicViewChildren(erasing: children)
    }
    
    @_transparent
    public var body: some View {
        children
    }
}

extension _TypedVariadicView {
    public subscript<Key: _ViewTraitKey, Value>(
        _ key: Key.Type
    ) -> Value? where Key.Value == Optional<Value> {
        for child in children {
            if let result = child[key] {
                return result
            }
        }
        
        return nil
    }

    public subscript<Key: _ViewTraitKey, Value>(
        trait key: KeyPath<_ViewTraitKeys, Key.Type>
    ) -> Value? where Key.Value == Optional<Value> {
        self[_ViewTraitKeys()[keyPath: key]]
    }
}
