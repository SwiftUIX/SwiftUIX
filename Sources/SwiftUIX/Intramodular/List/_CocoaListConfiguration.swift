//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol _CocoaListConfigurationType {
    associatedtype Data: _CocoaListDataSourceType
    associatedtype ViewProvider: _CocoaListViewProviderType where Data.ItemType == ViewProvider.ItemType, Data.SectionType == ViewProvider.SectionType
    
    var data: Data { get }
    var viewProvider: ViewProvider { get }
    var preferences: _CocoaListPreferences { get set }
}

@_documentation(visibility: internal)
public struct _CocoaListConfiguration<Data: _CocoaListDataSourceType, ViewProvider: _CocoaListViewProviderType>: _CocoaListConfigurationType where Data.SectionType == ViewProvider.SectionType, Data.ItemType == ViewProvider.ItemType {
    public let data: Data
    public let viewProvider: ViewProvider
    public var preferences: _CocoaListPreferences = nil
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
