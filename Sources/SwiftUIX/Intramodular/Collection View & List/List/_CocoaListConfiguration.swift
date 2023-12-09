//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol _CocoaListConfigurationType {
    associatedtype Data: _CocoaListDataType
    associatedtype ViewProvider: _CocoaListViewProviderType where Data.ItemType == ViewProvider.ItemType, Data.SectionType == ViewProvider.SectionType
    
    var data: Data { get }
    var viewProvider: ViewProvider { get }
}

public struct _CocoaListConfiguration<Data: _CocoaListDataType, ViewProvider: _CocoaListViewProviderType>: _CocoaListConfigurationType where Data.SectionType == ViewProvider.SectionType, Data.ItemType == ViewProvider.ItemType {
    public let data: Data
    public let viewProvider: ViewProvider
}

public protocol _CocoaListDataType {
    associatedtype SectionType
    associatedtype ItemType
    
    var payload: AnyRandomAccessCollection<ListSection<SectionType, ItemType>> { get }
    var sectionID: KeyPath<SectionType, AnyHashable> { get }
    var itemID: KeyPath<ItemType, AnyHashable> { get }
}

public protocol _CocoaListViewProviderType {
    associatedtype SectionType
    associatedtype ItemType
    associatedtype SectionHeader: View
    associatedtype SectionFooter: View
    associatedtype RowContent: View
    
    var rowContent: (ItemType) -> RowContent { get }
}

public struct _CocoaListViewProvider<
    SectionType,
    ItemType,
    SectionHeader: View,
    SectionFooter: View,
    RowContent: View
>: _CocoaListViewProviderType {
    public let sectionHeader: (SectionType) -> SectionHeader
    public let sectionFooter: (SectionType) -> SectionFooter
    public let rowContent: (ItemType) -> RowContent
}

public struct _CocoaListData<SectionType, ItemType>: _CocoaListDataType {
    public var payload: AnyRandomAccessCollection<ListSection<SectionType, ItemType>>
    public let sectionID: KeyPath<SectionType, AnyHashable>
    public let itemID: KeyPath<ItemType, AnyHashable>
    
    public init(
        payload: AnyRandomAccessCollection<ListSection<SectionType, ItemType>>,
        sectionID: KeyPath<SectionType, AnyHashable>,
        itemID: KeyPath<ItemType, AnyHashable>
    ) {
        self.payload = payload
        self.sectionID = sectionID
        self.itemID = itemID
    }
    
    public init<Data: RandomAccessCollection>(
        _ data: Data
    ) where Data.Element == ListSection<SectionType, ItemType>, SectionType: Identifiable, ItemType: Identifiable {
        self.init(
            payload: AnyRandomAccessCollection(data),
            sectionID: \.id._SwiftUIX_erasedAsAnyHashable,
            itemID: \.id._SwiftUIX_erasedAsAnyHashable
        )
    }
}

// MARK: - Auxiliary

extension Hashable {
    var _SwiftUIX_erasedAsAnyHashable: AnyHashable {
        AnyHashable(self)
    }
}
