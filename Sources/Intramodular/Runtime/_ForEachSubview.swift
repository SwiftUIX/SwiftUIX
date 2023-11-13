//
// Copyright (c) Vatsal Maot
//

import SwiftUI

@frozen
public struct _ForEachSubview<Content: View, ID: Hashable, Subview: View>: View {
    private let content: _TypedVariadicView<Content>
    private let id: KeyPath<_VariadicViewChildren.Subview, ID>
    private let subview: (Int, _VariadicViewChildren.Subview) -> Subview
    private var transform: ((_VariadicViewChildren) -> [_VariadicViewChildren.Subview])?
    
    public var body: some View {
        if let transform {
            ForEach(
                transform(content.children)._enumerated(),
                id: \.element[_keyPath: id]
            ) { (index, element) in
                subview(index, element)
                    .id(element[_keyPath: id])
            }
        } else {
            ForEach(
                content.children._enumerated(),
                id: \.element[_keyPath: id]
            ) { (index, element) in
                subview(index, element)
                    .id(element[_keyPath: id])
            }
        }
    }

    public init(
        enumerating content: _TypedVariadicView<Content>,
        id: KeyPath<_VariadicViewChildren.Subview, ID>,
        @ViewBuilder _ subview: @escaping (Int, _VariadicViewChildren.Subview) -> Subview
    ) {
        self.content = content
        self.id = id
        self.subview = subview
        self.transform = nil
    }
    
    public init<Trait: _ViewTraitKey>(
        enumerating content: _TypedVariadicView<Content>,
        trait: KeyPath<_ViewTraitKeys, Trait.Type>,
        id: KeyPath<Trait.Value, ID>,
        @ViewBuilder content subview: @escaping (Int, _VariadicViewChildren.Subview) -> Subview
    ) {
        self.content = content
        self.id = (\_VariadicViewChildren.Subview[trait: trait]).appending(path: id)
        self.subview = subview
        self.transform = nil
    }
    
    public init<Trait: _ViewTraitKey>(
        enumerating content: _TypedVariadicView<Content>,
        trait: KeyPath<_ViewTraitKeys, Trait.Type>,
        id: KeyPath<Trait.Value, ID?>,
        @ViewBuilder content subview: @escaping (Int, _VariadicViewChildren.Subview) -> Subview
    ) {
        self.content = content
        self.id = (\_VariadicViewChildren.Subview[trait: trait])
            .appending(path: id)
            .appending(path: \.unsafelyUnwrapped)
        self.subview = subview
        self.transform = nil
    }
}

extension _ForEachSubview {
    public init<Trait: _ViewTraitKey, UnwrappedTraitValue, _Subview: View>(
        _ source: _TypedVariadicView<Content>,
        trait: KeyPath<_ViewTraitKeys, Trait.Type>,
        @ViewBuilder content: @escaping (_VariadicViewChildren.Subview, UnwrappedTraitValue) -> _Subview
    ) where Trait.Value == Optional<UnwrappedTraitValue>, UnwrappedTraitValue: Identifiable, ID == Optional<UnwrappedTraitValue.ID>, Subview == AnyView {
        self.init(
            enumerating: source,
            trait: trait,
            id: \.?.id
        ) { (index: Int, subview: _VariadicViewChildren.Subview) -> AnyView in
            if let traitValue = subview[trait: trait] {
                return content(subview, traitValue)
                    .eraseToAnyView()
            } else {
                return EmptyView()
                    .eraseToAnyView()
            }
        }
    }
    
    public init<Trait: _ViewTraitKey, UnwrappedTraitValue, _Subview: View>(
        enumerating source: _TypedVariadicView<Content>,
        trait: KeyPath<_ViewTraitKeys, Trait.Type>,
        @ViewBuilder content: @escaping (Int, _VariadicViewChildren.Subview, UnwrappedTraitValue) -> _Subview
    ) where Trait.Value == Optional<UnwrappedTraitValue>, UnwrappedTraitValue: Identifiable, ID == Optional<UnwrappedTraitValue.ID>, Subview == _ConditionalContent<_Subview, EmptyView> {
        self.init(
            enumerating: source,
            trait: trait,
            id: \.?.id
        ) { (index: Int, subview: _VariadicViewChildren.Subview) -> _ConditionalContent<_Subview, EmptyView> in
            if let traitValue = subview[trait: trait] {
                return ViewBuilder.buildEither(first: content(index, subview, traitValue))
            } else {
                return ViewBuilder.buildEither(second: EmptyView())
            }
        }
    }
    
    public init<Key: _ViewTraitKey>(
        enumerating content: _TypedVariadicView<Content>,
        id: KeyPath<_ViewTraitKeys, Key.Type>,
        @ViewBuilder subview: @escaping (Int, _VariadicViewChildren.Subview) -> Subview
    ) where ID == Key.Value {
        self.init(
            enumerating: content,
            id: \_VariadicViewChildren.Subview.[trait: id],
            subview
        )
    }
    
    public init(
        _ content: _TypedVariadicView<Content>,
        @ViewBuilder subview: @escaping (_VariadicViewChildren.Subview) -> Subview
    ) where ID == AnyHashable {
        self.init(enumerating: content, id: \.id, { index, child in subview(child) })
    }
    
    public init(
        enumerating content: _TypedVariadicView<Content>,
        @ViewBuilder enumerating subview: @escaping (Int, _VariadicViewChildren.Subview) -> Subview
    ) where ID == AnyHashable {
        self.init(enumerating: content, id: \.id, subview)
    }
    
    public init(
        enumerating content: _TypedVariadicView<Content>,
        @ViewBuilder subview: @escaping (Int, _VariadicViewChildren.Subview) -> Subview
    ) where ID == AnyHashable {
        self.init(
            enumerating: content,
            id: \.id,
            subview
        )
    }
}

extension _ForEachSubview {
    public func _transformSubviews(
        _ transform: @escaping (_VariadicViewChildren) -> [_VariadicViewChildren.Subview]
    ) -> Self {
        then({ $0.transform = transform })
    }
}

@frozen
public struct _TypedVariadicView<Content: View>: View {
    public var children: _VariadicViewChildren
    
    public var isEmpty: Bool {
        children.isEmpty
    }
    
    init(_ children: _VariadicView.Children) {
        self.children = _VariadicViewChildren(erasing: children)
    }
    
    public var body: some View {
        children
    }
}

@frozen
public struct _VariadicViewAdapter<Source: View, Content: View>: View {
    private struct Root: _VariadicView.MultiViewRoot {
        var content: (_TypedVariadicView<Source>) -> Content
        
        func body(children: _VariadicView.Children) -> some View {
            content(_TypedVariadicView(children))
        }
    }
    
    private let source: Source
    private let content: (_TypedVariadicView<Source>) -> Content
    
    public init(
        _ source: Source,
        @ViewBuilder content: @escaping (_TypedVariadicView<Source>) -> Content
    ) {
        self.source = source
        self.content = content
    }
    
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

    public var body: some View {
        _VariadicView.Tree(Root(content: content)) {
            source
        }
    }
}

// MARK: - Internal

extension Collection {
    fileprivate func _enumerated() -> LazyMapCollection<Self.Indices, (index: Self.Index, element: Self.Element)> {
        indices.lazy.map({ (index: $0, element: self[$0]) })
    }
}
