//
// Copyright (c) Vatsal Manot
//

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
    public init<_Data: RandomAccessCollection, _ID: Hashable>(
        _ data: _Data,
        id: KeyPath<_Data.Element, _ID>,
        @ViewBuilder content: @escaping (_Data.Element) -> Content
    ) {
        let collection = AnyRandomAccessCollection(data.indices.lazy.map({ AnyForEachElement(index: AnyIndex($0), value: data[$0], id: data[$0][keyPath: id]) }))
        
        self.init(collection, id: \.id) { (element: AnyForEachElement) in
            content(collection[element.index].value as! _Data.Element)
        }
    }
    
    public init<_Data: RandomAccessCollection, _ID: Hashable>(
        _ data: ForEach<_Data, _ID, Content>
    ) where _Data.Element: Identifiable {
        self.init(data.data, id: \.id, content: data.content)
    }
    
    public init<_Data: RandomAccessCollection, _ID: Hashable>(
        _ content: ForEach<_Data, _ID, Content>
    ) {
        let data = content.data
        let content = content.content
        
        // FIXME! - This is a poor hack until `id` is exposed publicly by `ForEach`
        self.init(
            data.lazy.indices.map({ data.distance(from: data.startIndex, to: $0) }),
            id: \.self,
            content: {
                content(data[data.index(data.startIndex, offsetBy: $0)])
            }
        )
    }
}
