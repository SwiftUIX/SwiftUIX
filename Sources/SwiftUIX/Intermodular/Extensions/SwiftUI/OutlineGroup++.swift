//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension OutlineGroup where ID == Data.Element.ID, Parent : View, Parent == Leaf, Subgroup == DisclosureGroup<Parent, OutlineSubgroupChildren>, Data.Element : Identifiable {
    public init<DataElement: Identifiable>(
        _ data: Data,
        children: KeyPath<DataElement, Data>,
        @ViewBuilder content: @escaping (DataElement) -> Leaf
    ) where ID == DataElement.ID, DataElement == Data.Element {
        self.init(
            data,
            children: children.appending(path: \._nilIfEmpty),
            content: content
        )
    }
}

// MARK: - Helpers

extension RandomAccessCollection {
    fileprivate var _nilIfEmpty: Self? {
        guard !isEmpty else {
            return nil
        }
        
        return self
    }
}
