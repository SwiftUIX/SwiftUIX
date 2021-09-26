//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension ForEach {
    public var isEmpty: Bool {
        data.isEmpty
    }
    
    public var count: Int {
        data.count
    }
}

extension ForEach where Content: View {
    public init<_Element>(
        _ data: Data,
        @ViewBuilder content: @escaping (_Element) -> Content
    ) where Data.Element == KeyPathHashIdentifiableValue<_Element, ID> {
        self.init(data) {
            content($0.value)
        }
    }
    
    public init<Elements: RandomAccessCollection>(
        enumerating data: Elements,
        id: KeyPath<Elements.Element, ID>,
        @ViewBuilder rowContent: @escaping (Int, Elements.Element) -> Content
    ) where Data == [_KeyPathIdentifiableElementOffsetPair<Elements.Element, Int, ID>] {
        self.init(data.enumerated().map({ _KeyPathIdentifiableElementOffsetPair(element: $0.element, offset: $0.offset, id: id) })) {
            rowContent($0.offset, $0.element)
        }
    }
    
    public init<Elements: RandomAccessCollection>(
        enumerating data: Elements,
        @ViewBuilder rowContent: @escaping (Int, Elements.Element) -> Content
    ) where Elements.Element: Identifiable, Data == [_IdentifiableElementOffsetPair<Elements.Element, Int>], ID == Elements.Element.ID {
        self.init(data.enumerated().map({ _IdentifiableElementOffsetPair(element: $0.element, offset: $0.offset) })) {
            rowContent($0.offset, $0.element)
        }
    }
}

extension ForEach where Data.Element: Identifiable, Content: View, ID == Data.Element.ID {
    public func interleave<Separator: View>(with separator: Separator) -> some View {
        let data = self.data.enumerated().map({ _IdentifiableElementOffsetPair(element: $0.element, offset: $0.offset) })
        
        return ForEach<[_IdentifiableElementOffsetPair<Data.Element, Int>], Data.Element.ID,  Group<TupleView<(Content, Separator?)>>>(data) { pair in
            Group {
                self.content(pair.element)
                
                if pair.offset != (data.count - 1) {
                    separator
                }
            }
        }
    }
}

extension ForEach where Data.Element: Identifiable, Content: View, ID == Data.Element.ID {
    public func interdivided() -> some View {
        let data = self.data.enumerated().map({ _IdentifiableElementOffsetPair(element: $0.element, offset: $0.offset) })
        
        return ForEach<[_IdentifiableElementOffsetPair<Data.Element, Int>], Data.Element.ID,  Group<TupleView<(Content, Divider?)>>>(data) { pair in
            Group {
                self.content(pair.element)
                
                if pair.offset != (data.count - 1) {
                    Divider()
                }
            }
        }
    }
}

extension ForEach where Data.Element: Identifiable, Content: View, ID == Data.Element.ID {
    public func interspaced() -> some View {
        let data = self.data.enumerated().map({ _IdentifiableElementOffsetPair(element: $0.element, offset: $0.offset) })
        
        return ForEach<[_IdentifiableElementOffsetPair<Data.Element, Int>], Data.Element.ID,  Group<TupleView<(Content, Spacer?)>>>(data) { pair in
            Group {
                self.content(pair.element)
                
                if pair.offset != (data.count - 1) {
                    Spacer()
                }
            }
        }
    }
}

extension ForEach where Content: View {
    @_disfavoredOverload
    public init<_Data: MutableCollection>(
        _ data: Binding<_Data>,
        id: KeyPath<_Data.Element, ID>,
        @ViewBuilder content: @escaping (Binding<_Data.Element>) -> Content,
        _: () = ()
    ) where Data == LazyMapSequence<LazySequence<_Data.Indices>.Elements, Binding<_Data.Element>> {
        let collection = data.wrappedValue.indices.lazy.map { index -> Binding<_Data.Element> in
            let element = data.wrappedValue[index]
            
            return Binding(
                get: { () -> _Data.Element in
                    if index < data.wrappedValue.endIndex {
                        return data.wrappedValue[index]
                    } else {
                        return element
                    }
                },
                set: {
                    if index < data.wrappedValue.endIndex {
                        data.wrappedValue[index] = $0
                    }
                }
            )
        }
        
        self.init(collection, id: \._bindingIdentifiableKeyPathAdaptor[keyPath: id]) {
            content($0)
        }
    }
}


// MARK: - Auxiliary Implementation -

extension Binding {
    fileprivate struct _BindingIdentifiableKeyPathAdaptor {
        let base: Binding<Value>
        
        subscript<ID>(keyPath keyPath: KeyPath<Value, ID>) -> ID {
            base.wrappedValue[keyPath: keyPath]
        }
    }
    
    fileprivate var _bindingIdentifiableKeyPathAdaptor: _BindingIdentifiableKeyPathAdaptor {
        .init(base: self)
    }
}

extension RandomAccessCollection {
    public func elements<ID>(
        identifiedBy id: KeyPath<Element, ID>
    ) -> AnyRandomAccessCollection<KeyPathHashIdentifiableValue<Element, ID>> {
        .init(lazy.map({ KeyPathHashIdentifiableValue(value: $0, keyPath: id) }))
    }
}

public struct _IdentifiableElementOffsetPair<Element: Identifiable, Offset>: Identifiable {
    let element: Element
    let offset: Offset
    
    public var id: Element.ID {
        element.id
    }
    
    init(element: Element, offset: Offset) {
        self.element = element
        self.offset = offset
    }
}

public struct _KeyPathIdentifiableElementOffsetPair<Element, Offset, ID: Hashable>: Identifiable {
    let element: Element
    let offset: Offset
    let keyPathToID: KeyPath<Element, ID>
    
    public var id: ID {
        element[keyPath: keyPathToID]
    }
    
    init(element: Element, offset: Offset, id: KeyPath<Element, ID>) {
        self.element = element
        self.offset = offset
        self.keyPathToID = id
    }
}
