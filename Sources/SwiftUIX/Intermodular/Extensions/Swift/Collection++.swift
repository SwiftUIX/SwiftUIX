//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension Collection {
    public subscript(_ indexSet: IndexSet) -> AnyBidirectionalCollection<Element> {
        AnyBidirectionalCollection(
            indexSet.lazy.map { index in
                self[self.index(self.startIndex, offsetBy: index)]
            } as LazyMapCollection
        )
    }
}
