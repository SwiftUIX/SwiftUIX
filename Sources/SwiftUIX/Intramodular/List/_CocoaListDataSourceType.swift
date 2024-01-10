//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol _CocoaListDataSourceType<SectionType, ItemType>: Identifiable {
    associatedtype SectionType
    associatedtype ItemType
    
    var payload: AnyRandomAccessCollection<ListSection<SectionType, ItemType>> { get }
    var sectionID: KeyPath<SectionType, _AnyCocoaListSectionID> { get }
    var itemID: KeyPath<ItemType, _AnyCocoaListItemID> { get }
}

// MARK: - Extensions

extension _CocoaListDataSourceType {
    public var itemsCount: Int {
        payload.map({ $0.items.count }).reduce(into: 0, +=)
    }
}

// MARK: - Auxiliary

public struct _DefaultCocoaListDataSourceID: Hashable {
    let rawValue: [ListSection<_AnyCocoaListSectionID, _AnyCocoaListItemID>]
    
    init(rawValue: [ListSection<_AnyCocoaListSectionID, _AnyCocoaListItemID>]) {
        self.rawValue = rawValue
    }
    
    init<Section, SectionID: Hashable, Item, ItemID: Hashable>(
        _ data: some Sequence<ListSection<Section, Item>>,
        section: KeyPath<Section, SectionID>,
        item: KeyPath<Item, ItemID>
    ) {
        self.rawValue = data.map { (data: ListSection) in
            data
                .map {
                    _AnyCocoaListSectionID($0[keyPath: section])
                }
                .mapItems {
                    _AnyCocoaListItemID( $0[keyPath: item])
                }
        }
    }
    
    init(from data: some _CocoaListDataSourceType) {
        self.init(
            data.payload,
            section: data.sectionID,
            item: data.itemID
        )
    }
}

extension _CocoaListDataSourceType where ID == _DefaultCocoaListDataSourceID {
    public var id: ID {
        ID(from: self)
    }
}

// MARK: - Implemented Conformances

public struct _AnyCocoaListDataSource<SectionType, ItemType>: _CocoaListDataSourceType {
    public typealias ID = _DefaultCocoaListDataSourceID
    
    public var payload: AnyRandomAccessCollection<ListSection<SectionType, ItemType>>
    public let sectionID: KeyPath<SectionType, _AnyCocoaListSectionID>
    public let itemID: KeyPath<ItemType, _AnyCocoaListItemID>
    public let id: ID
    
    public init(
        payload: AnyRandomAccessCollection<ListSection<SectionType, ItemType>>,
        sectionID: KeyPath<SectionType, _AnyCocoaListSectionID>,
        itemID: KeyPath<ItemType, _AnyCocoaListItemID>
    ) {
        self.payload = payload
        self.sectionID = sectionID
        self.itemID = itemID
        self.id = ID(payload, section: sectionID, item: itemID)
    }
    
    public init<Data: RandomAccessCollection>(
        _ data: Data
    ) where Data.Element == ListSection<SectionType, ItemType>, SectionType: Identifiable, ItemType: Identifiable {
        self.init(
            payload: AnyRandomAccessCollection(data),
            sectionID: \.id._SwiftUIX_erasedAsCocoaListSectionID,
            itemID: \.id._SwiftUIX_erasedAsCocoaListItemID
        )
    }
}
