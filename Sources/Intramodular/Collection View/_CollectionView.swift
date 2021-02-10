//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

struct _CollectionView<
    SectionType,
    SectionIdentifierType: Hashable,
    ItemType,
    ItemIdentifierType: Hashable,
    SectionHeader: View,
    SectionFooter: View,
    RowContent: View
>: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIHostingCollectionViewController<
        SectionType,
        SectionIdentifierType,
        ItemType,
        ItemIdentifierType,
        SectionHeader,
        SectionFooter,
        RowContent
    >
    
    private let dataSource: UIViewControllerType.DataSource
    private let dataSourceIdentifierMap: UIViewControllerType.DataSource.IdentifierMap
    private let sectionHeader: (SectionType) -> SectionHeader
    private let sectionFooter: (SectionType) -> SectionFooter
    private let rowContent: (ItemType) -> RowContent
    
    public func makeUIViewController(context: Context) -> UIViewControllerType {
        .init(
            dataSourceIdentifierMap: dataSourceIdentifierMap,
            sectionHeader: sectionHeader,
            sectionFooter: sectionFooter,
            rowContent: rowContent
        )
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController.dataSource = dataSource
        uiViewController.sectionHeader = sectionHeader
        uiViewController.sectionFooter = sectionFooter
        uiViewController.rowContent = rowContent
        
        uiViewController.collectionView.configure(with: context.environment._scrollViewConfiguration)
        
        if uiViewController.collectionViewLayout.hashValue != context.environment.collectionViewLayout.hashValue {
            uiViewController.collectionViewLayout = context.environment.collectionViewLayout._toUICollectionViewLayout()
        }
    }
}

extension _CollectionView {
    init(
        _ dataSource: UIViewControllerType.DataSource,
        sectionHeader: @escaping (SectionType) -> SectionHeader,
        sectionFooter: @escaping (SectionType) -> SectionFooter,
        rowContent: @escaping (ItemType) -> RowContent
    ) where
    SectionType: Hashable,
    ItemType: Hashable,
    SectionIdentifierType == SectionType,
    ItemIdentifierType == ItemType
    {
        self.dataSourceIdentifierMap = .init(
            getSectionID: { $0 },
            getSectionFromID: { $0 },
            getItemID: { $0 },
            getItemFromID: { $0 }
        )
        self.dataSource = dataSource
        self.sectionHeader = sectionHeader
        self.sectionFooter = sectionFooter
        self.rowContent = rowContent
    }
    
    init<Data: RandomAccessCollection>(
        _ data: Data,
        sectionHeader: @escaping (SectionType) -> SectionHeader,
        sectionFooter: @escaping (SectionType) -> SectionFooter,
        rowContent: @escaping (ItemType) -> RowContent
    ) where
        SectionType: Hashable,
        ItemType: Hashable,
        Data.Element == ListSection<SectionType, ItemType>,
        SectionIdentifierType == SectionType, ItemIdentifierType == ItemType
    {
        self.init(
            .static(.init(data)),
            sectionHeader: sectionHeader,
            sectionFooter: sectionFooter,
            rowContent: rowContent
        )
    }
}

#endif
