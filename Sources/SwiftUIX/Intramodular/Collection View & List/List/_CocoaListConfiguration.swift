//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol _CocoaListViewProviderType {
    associatedtype SectionType
    associatedtype ItemType
    associatedtype SectionHeader: View
    associatedtype SectionFooter: View
    associatedtype RowContent: View
    
    var rowContent: (ItemType) -> RowContent { get }
}

public protocol _CocoaListConfigurationType {
    associatedtype Data: _CocoaListDataSourceType
    associatedtype ViewProvider: _CocoaListViewProviderType where Data.ItemType == ViewProvider.ItemType, Data.SectionType == ViewProvider.SectionType
    
    var data: Data { get }
    var viewProvider: ViewProvider { get }
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

public struct _CocoaListConfiguration<Data: _CocoaListDataSourceType, ViewProvider: _CocoaListViewProviderType>: _CocoaListConfigurationType where Data.SectionType == ViewProvider.SectionType, Data.ItemType == ViewProvider.ItemType {
    public let data: Data
    public let viewProvider: ViewProvider
}

// MARK: - Auxiliary

extension Hashable {
    var _SwiftUIX_erasedAsAnyHashable: AnyHashable {
        AnyHashable(self)
    }
    
    var _SwiftUIX_erasedAsCocoaListSectionID: _AnyCocoaListSectionID {
        _AnyCocoaListSectionID(self)
    }

    var _SwiftUIX_erasedAsCocoaListItemID: _AnyCocoaListItemID {
        _AnyCocoaListItemID(self)
    }
}
