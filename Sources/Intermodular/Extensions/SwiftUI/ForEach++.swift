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
