//
// Copyright (c) Vatsal Manot
//

import SwiftUI

public protocol _CocoaListViewProviderType {
    associatedtype SectionType
    associatedtype ItemType
    associatedtype SectionHeader: View
    associatedtype SectionFooter: View
    associatedtype RowContent: View
    
    var rowContent: (ItemType) -> RowContent { get }
}

@_documentation(visibility: internal)
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
