//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public typealias AnyForEachData = AnyRandomAccessCollection<AnyForEachElement>
public typealias AnyForEach<Content> = ForEach<AnyForEachData, AnyHashable, Content>

public struct AnyForEachElement: Identifiable {
    public let index: AnyIndex
    public let value: Any
    public let id: AnyHashable
}

extension ForEach where Content: View, Data == AnyForEachData, ID == AnyHashable {
    @_disfavoredOverload
    public init<Data: RandomAccessCollection, ID: Hashable>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        let collection = AnyRandomAccessCollection(data.indices.lazy.map({ AnyForEachElement(index: AnyIndex($0), value: data[$0], id: data[$0][keyPath: id]) }))
        
        self.init(collection, id: \.id) { (element: AnyForEachElement) in
            content(collection[element.index].value as! Data.Element)
        }
    }
    
    public init<Data: RandomAccessCollection, ID: Hashable>(
        _ data: ForEach<Data, ID, Content>
    ) where Data.Element: Identifiable {
        self.init(data.data, id: \.id, content: data.content)
    }
    
    public init<Data: RandomAccessCollection, ID: Hashable>(
        _ content: ForEach<Data, ID, Content>
    ) {
        let data = content.data
        let content = content.content
        
        self.init(data.lazy.indices.map({ data.distance(from: data.startIndex, to: $0) }), id: \.self, content: { content(data[data.index(data.startIndex, offsetBy: $0)]) }) // FIXME! - This is a poor hack until `id` is exposed publicly by `ForEach`
    }
}
