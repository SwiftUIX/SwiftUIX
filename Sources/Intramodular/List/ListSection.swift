//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct ListSection<Model, Item> {
    private var _model: Model!
    
    public var model: Model {
        get {
            _model
        } set {
            _model = newValue
        }
    }
    
    public let items: [Item]
    
    public init(
        model: Model,
        items: [Item]
    ) {
        self._model = model
        self.items = items
    }
}

extension ListSection where Model == Never {
    public init(items: [Item]) {
        self._model = nil
        self.items = items
    }
    
    public init<C: Collection>(items: C) where C.Element == Item {
        self.init(items: Array(items))
    }
}

// MARK: - Helpers -

extension Collection  {
    subscript<SectionModel, Item>(_ indexPath: IndexPath) -> Item where Element == ListSection<SectionModel, Item> {
        get {
            let sectionIndex = index(startIndex, offsetBy: indexPath.section)
            let rowIndex = self[sectionIndex]
                .items
                .index(self[sectionIndex].items.startIndex, offsetBy: indexPath.row)
            
            return self[sectionIndex].items[rowIndex]
        }
    }
}

