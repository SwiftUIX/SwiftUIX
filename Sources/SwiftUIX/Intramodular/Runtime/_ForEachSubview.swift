//
// Copyright (c) Vatsal Manot
//

import SwiftUI

@frozen
public struct _ForEachSubview<Content: View, ID: Hashable, Subview: View>: View {
    private let content: _SwiftUI_VariadicView<Content>
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
        enumerating content: _SwiftUI_VariadicView<Content>,
        id: KeyPath<_VariadicViewChildren.Subview, ID>,
        @ViewBuilder _ subview: @escaping (Int, _VariadicViewChildren.Subview) -> Subview
    ) {
        self.content = content
        self.id = id
        self.subview = subview
        self.transform = nil
    }
    
    public init<Trait: _ViewTraitKey>(
        enumerating content: _SwiftUI_VariadicView<Content>,
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
        enumerating content: _SwiftUI_VariadicView<Content>,
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
        _ source: _SwiftUI_VariadicView<Content>,
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
        enumerating source: _SwiftUI_VariadicView<Content>,
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
        enumerating content: _SwiftUI_VariadicView<Content>,
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
        _ content: _SwiftUI_VariadicView<Content>,
        @ViewBuilder subview: @escaping (_VariadicViewChildren.Subview) -> Subview
    ) where ID == AnyHashable {
        self.init(enumerating: content, id: \.id, { index, child in subview(child) })
    }
    
    public init(
        enumerating content: _SwiftUI_VariadicView<Content>,
        @ViewBuilder enumerating subview: @escaping (Int, _VariadicViewChildren.Subview) -> Subview
    ) where ID == AnyHashable {
        self.init(enumerating: content, id: \.id, subview)
    }
    
    public init(
        enumerating content: _SwiftUI_VariadicView<Content>,
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

// MARK: - Internal

extension Collection {
    @_transparent
    fileprivate func _enumerated() -> LazyMapCollection<Self.Indices, (index: Self.Index, element: Self.Element)> {
        indices.lazy.map({ (index: $0, element: self[$0]) })
    }
}
