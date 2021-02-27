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
    
    struct DataSourceConfiguration {
        let identifierMap: UIViewControllerType.DataSource.IdentifierMap
    }
    
    struct ViewProvider {
        let sectionHeader: (SectionType) -> SectionHeader
        let sectionFooter: (SectionType) -> SectionFooter
        let rowContent: (ItemType) -> RowContent
    }
    
    typealias Configuration = _CollectionViewConfiguration
    
    private let dataSource: UIViewControllerType.DataSource
    private let dataSourceConfiguration: DataSourceConfiguration
    private let viewProvider: ViewProvider
    
    @Environment(\._collectionViewConfiguration) var configuration: Configuration
    
    public func makeUIViewController(context: Context) -> UIViewControllerType {
        .init(
            dataSourceConfiguration: dataSourceConfiguration,
            viewProvider: viewProvider,
            configuration: configuration
        )
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        if let _collectionViewProxy = context.environment._collectionViewProxy {
            if _collectionViewProxy.wrappedValue.hostingCollectionViewController !== uiViewController {
                DispatchQueue.main.async {
                    _collectionViewProxy.wrappedValue.hostingCollectionViewController = uiViewController
                }
            }
        }

        uiViewController.dataSource = dataSource
        uiViewController.dataSourceConfiguration = dataSourceConfiguration
        uiViewController._dynamicViewContentTraitValues = context.environment._dynamicViewContentTraitValues
        uiViewController._scrollViewConfiguration = context.environment._scrollViewConfiguration
        uiViewController.configuration = context.environment._collectionViewConfiguration
        uiViewController.viewProvider = viewProvider
                
        if uiViewController.collectionViewLayout.hashValue != context.environment.collectionViewLayout.hashValue {
            uiViewController.collectionViewLayout = context.environment.collectionViewLayout
        }
    }
}

// MARK: - Initializers -

extension _CollectionView {
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

extension _CollectionView where
    SectionType: Hashable,
    ItemType: Hashable,
    SectionIdentifierType == SectionType,
    ItemIdentifierType == ItemType
{
    init(
        _ dataSource: UIViewControllerType.DataSource,
        sectionHeader: @escaping (SectionType) -> SectionHeader,
        sectionFooter: @escaping (SectionType) -> SectionFooter,
        rowContent: @escaping (ItemType) -> RowContent
    ) {
        self.dataSource = dataSource
        self.dataSourceConfiguration = .init(
            identifierMap: .init(
                getSectionID: { $0 },
                getSectionFromID: { $0 },
                getItemID: { $0 },
                getItemFromID: { $0 }
            )
        )
        self.viewProvider = .init(
            sectionHeader: sectionHeader,
            sectionFooter: sectionFooter,
            rowContent: rowContent
        )
    }
}

#endif
