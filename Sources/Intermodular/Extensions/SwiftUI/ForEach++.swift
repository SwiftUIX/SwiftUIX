//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension ForEach where Content: View {
    public init<Elements: RandomAccessCollection, ElementID: Hashable>(
        _ data: Elements,
        id: KeyPath<Elements.Element, ElementID>,
        @ViewBuilder rowContent: @escaping (Elements.Element) -> Content
    ) where Data == LazyMapSequence<Elements, KeyPathHashIdentifiableValue<Elements.Element, ElementID>>, ID == HashIdentifiableValue<ElementID> {
        
        self.init(data.lazy.map({ KeyPathHashIdentifiableValue(value: $0, keyPath: id) })) {
            rowContent($0.value)
        }
    }
}

extension ForEach where Data.Element: Identifiable, Content: View, ID == Data.Element.ID {
    public func interdivided() -> some View {
        let data = self.data.enumerated().map({ ElementOffsetPair(element: $0.element, offset: $0.offset) })
        
        return ForEach<[ElementOffsetPair<Data.Element, Int>], Data.Element.ID,  Group<TupleView<(Content, Divider?)>>>(data) { pair in
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
        let data = self.data.enumerated().map({ ElementOffsetPair(element: $0.element, offset: $0.offset) })
        
        return ForEach<[ElementOffsetPair<Data.Element, Int>], Data.Element.ID,  Group<TupleView<(Content, Spacer?)>>>(data) { pair in
            Group {
                self.content(pair.element)
                
                if pair.offset != (data.count - 1) {
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Helpers -

fileprivate struct ElementOffsetPair<Element: Identifiable, Offset>: Identifiable {
    let element: Element
    let offset: Offset
    
    var id: Element.ID {
        element.id
    }
    
    init(element: Element, offset: Offset) {
        self.element = element
        self.offset = offset
    }
}
