//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || os(visionOS)

/// WIP: Should be renamed to `_CocoaList`.
@_documentation(visibility: internal)
public struct CocoaList<
    SectionType: Identifiable,
    ItemType: Identifiable,
    Data: RandomAccessCollection,
    SectionHeader: View,
    SectionFooter: View,
    RowContent: View
>: UIViewControllerRepresentable where Data.Element == ListSection<SectionType, ItemType> {
    public typealias Offset = ScrollView<AnyView>.ContentOffset
    public typealias UIViewControllerType = _PlatformTableViewController<SectionType, ItemType, Data, SectionHeader, SectionFooter, RowContent>
    
    @usableFromInline
    let data: Data
    @usableFromInline
    let sectionHeader: (SectionType) -> SectionHeader
    @usableFromInline
    let sectionFooter: (SectionType) -> SectionFooter
    @usableFromInline
    let rowContent: (ItemType) -> RowContent
    
    @usableFromInline
    var style: UITableView.Style = .plain
    
    #if !os(tvOS)
    @usableFromInline
    var separatorStyle: UITableViewCell.SeparatorStyle = .singleLine
    #endif
    
    @usableFromInline
    var scrollViewConfiguration: CocoaScrollViewConfiguration<AnyView> = nil
    @usableFromInline
    var _cocoaListPreferences: _CocoaListPreferences = nil

    public init(
        _ data: Data,
        sectionHeader: @escaping (SectionType) -> SectionHeader,
        sectionFooter: @escaping (SectionType) -> SectionFooter,
        rowContent: @escaping (ItemType) -> RowContent
    ) {
        self.data = data
        self.sectionHeader = sectionHeader
        self.sectionFooter = sectionFooter
        self.rowContent = rowContent
    }
    
    public func makeUIViewController(
        context: Context
    ) -> UIViewControllerType {
        .init(
            data,
            style: style,
            sectionHeader: sectionHeader,
            sectionFooter: sectionFooter,
            rowContent: rowContent
        )
    }
    
    public func updateUIViewController(
        _ uiViewController: UIViewControllerType,
        context: Context
    ) {
        uiViewController.data = data
        uiViewController.sectionHeader = sectionHeader
        uiViewController.sectionFooter = sectionFooter
        uiViewController.rowContent = rowContent
        
        uiViewController.initialContentAlignment = context.environment.initialContentAlignment
        
        var scrollViewConfiguration = self.scrollViewConfiguration
        
        scrollViewConfiguration.update(from: context.environment)
        
        uiViewController.scrollViewConfiguration = scrollViewConfiguration
        
        #if !os(tvOS)
        uiViewController.tableView.separatorStyle = separatorStyle
        #endif
        
        uiViewController.reloadData()
    }
}

#endif
