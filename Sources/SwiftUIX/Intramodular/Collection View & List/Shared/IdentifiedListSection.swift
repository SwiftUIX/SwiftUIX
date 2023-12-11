//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct IdentifiedListSection<SectionType, SectionIdentifierType: Hashable, ItemType, ItemIdentifierType: Hashable> {
    public let model: SectionType
    public let items: [ItemType]
    public let sectionID: KeyPath<SectionType, SectionIdentifierType>
    public let itemID: KeyPath<ItemType, ItemIdentifierType>
    
    public init(
        _ data: ListSection<SectionType, ItemType>,
        section: KeyPath<SectionType, SectionIdentifierType>,
        item: KeyPath<ItemType, ItemIdentifierType>
    ) {
        self.model = data.model
        self.items = Array(data.items)
        self.sectionID = section
        self.itemID = item
    }
}

public struct IdentifiedListSections<SectionType, SectionIdentifierType: Hashable, ItemType, ItemIdentifierType: Hashable> {
    private let base: [IdentifiedListSection<SectionType, SectionIdentifierType, ItemType, ItemIdentifierType>]
    
    public init<Data: _CocoaListDataSourceType<SectionType, ItemType>>(
        from data: Data
    ) where SectionIdentifierType == _AnyCocoaListSectionID, ItemIdentifierType == _AnyCocoaListItemID {
        self.base = data.payload.map {
            IdentifiedListSection($0, section: data.sectionID, item: data.itemID)
        }
    }
}

extension IdentifiedListSection {
    public struct IdentifiersDifference: Hashable {
        public let itemsInserted: Set<ItemIdentifierType>
        public let itemsRemoved: Set<ItemIdentifierType>
    }
    
    public func identifiersDifference(
        from other: IdentifiedListSection
    ) -> IdentifiersDifference {
        let currentItemsSet = Set(self.items.map { $0[keyPath: self.itemID] })
        let otherItemsSet = Set(other.items.map { $0[keyPath: other.itemID] })
        
        let insertedItems = currentItemsSet.subtracting(otherItemsSet)
        let removedItems = otherItemsSet.subtracting(currentItemsSet)
    
        return .init(
            itemsInserted: insertedItems,
            itemsRemoved: removedItems
        )
    }
}

extension IdentifiedListSections {
    public struct IdentifiersDifference: Hashable {
        public let sectionsInserted: Set<SectionIdentifierType>
        public let sectionsRemoved: Set<SectionIdentifierType>
        public let itemsInsertedBySection: [SectionIdentifierType: Set<ItemIdentifierType>]
        public let itemsRemovedBySection: [SectionIdentifierType: Set<ItemIdentifierType>]
    }
}

extension IdentifiedListSections {
    public func identifiersDifference(from other: Self) -> IdentifiersDifference {
        let currentSectionsSet = Set(self.base.map { $0.model[keyPath: $0.sectionID] })
        let otherSectionsSet = Set(other.base.map { $0.model[keyPath: $0.sectionID] })
        
        let sectionsInserted = currentSectionsSet.subtracting(otherSectionsSet)
        let sectionsRemoved = otherSectionsSet.subtracting(currentSectionsSet)
        var itemsInsertedBySection = [SectionIdentifierType: Set<ItemIdentifierType>]()
        var itemsRemovedBySection = [SectionIdentifierType: Set<ItemIdentifierType>]()
        
        for section in self.base {
            let sectionID = section.model[keyPath: section.sectionID]
            
            if let otherSection = other.base.first(where: { $0.model[keyPath: $0.sectionID] == sectionID }) {
                let difference = section.identifiersDifference(from: otherSection)
            
                if !difference.itemsInserted.isEmpty {
                    itemsInsertedBySection[sectionID] = difference.itemsInserted
                }
                
                if !difference.itemsRemoved.isEmpty {
                    itemsRemovedBySection[sectionID] = difference.itemsRemoved
                }
            } else if sectionsInserted.contains(sectionID) {
                itemsInsertedBySection[sectionID] = Set(section.items.map { $0[keyPath: section.itemID] })
            }
        }
        
        for section in other.base {
            let sectionID = section.model[keyPath: section.sectionID]
            
            if sectionsRemoved.contains(sectionID) {
                itemsRemovedBySection[sectionID] = Set(section.items.map { $0[keyPath: section.itemID] })
            }
        }
        
        return IdentifiersDifference(
            sectionsInserted: sectionsInserted,
            sectionsRemoved: sectionsRemoved,
            itemsInsertedBySection: itemsInsertedBySection,
            itemsRemovedBySection: itemsRemovedBySection
        )
    }
}
