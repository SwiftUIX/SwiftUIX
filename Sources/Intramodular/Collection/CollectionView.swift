//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CollectionView<SectionModel: Identifiable, Item: Identifiable, Data: RandomAccessCollection, SectionHeader: View, SectionFooter: View, RowContent: View>: UIViewControllerRepresentable where Data.Element == ListSection<SectionModel, Item> {
    public typealias Offset = ScrollView<AnyView>.ContentOffset
    public typealias UIViewControllerType = UIHostingCollectionViewController<SectionModel, Item, Data, SectionHeader, SectionFooter, RowContent>
    
    private let data: Data
    private let sectionHeader: (SectionModel) -> SectionHeader
    private let sectionFooter: (SectionModel) -> SectionFooter
    private let rowContent: (Item) -> RowContent
    
    private var scrollViewConfiguration = CocoaScrollViewConfiguration<AnyView>()
    
    @Environment(\.collectionViewLayout) var collectionViewLayout
    @Environment(\.initialContentAlignment) var initialContentAlignment
    @Environment(\.isScrollEnabled) var isScrollEnabled
    
    public init(
        _ data: Data,
        sectionHeader: @escaping (SectionModel) -> SectionHeader,
        sectionFooter: @escaping (SectionModel) -> SectionFooter,
        rowContent: @escaping (Item) -> RowContent
    ) {
        self.data = data
        self.sectionHeader = sectionHeader
        self.sectionFooter = sectionFooter
        self.rowContent = rowContent
    }
    
    public func makeUIViewController(context: Context) -> UIViewControllerType {
        .init(
            data,
            collectionViewLayout: collectionViewLayout._toUICollectionViewLayout(),
            sectionHeader: sectionHeader,
            sectionFooter: sectionFooter,
            rowContent: rowContent
        )
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController.data = data
        uiViewController.sectionHeader = sectionHeader
        uiViewController.sectionFooter = sectionFooter
        uiViewController.rowContent = rowContent
        
        uiViewController.collectionView.configure(with: scrollViewConfiguration)
        
        let newCollectionViewLayout = collectionViewLayout._toUICollectionViewLayout()
        
        if uiViewController.collectionViewLayout !== newCollectionViewLayout, uiViewController.collectionViewLayout != newCollectionViewLayout {
            uiViewController.collectionView.setCollectionViewLayout(newCollectionViewLayout, animated: true)
        }
        
        uiViewController.reloadData()
    }
}

extension CollectionView {
    public init<_Item: Hashable>(
        _ data: Data,
        sectionHeader: @escaping (SectionModel) -> SectionHeader,
        sectionFooter: @escaping (SectionModel) -> SectionFooter,
        rowContent: @escaping (_Item) -> RowContent
    ) where Item == HashIdentifiableValue<_Item> {
        self.data = data
        self.sectionHeader = sectionHeader
        self.sectionFooter = sectionFooter
        self.rowContent = { rowContent($0.value) }
    }
    
    public init<_SectionModel: Hashable, _Item: Hashable>(
        _ data: Data,
        sectionHeader: @escaping (_SectionModel) -> SectionHeader,
        sectionFooter: @escaping (_SectionModel) -> SectionFooter,
        rowContent: @escaping (_Item) -> RowContent
    ) where SectionModel == HashIdentifiableValue<_SectionModel>, Item == HashIdentifiableValue<_Item> {
        self.data = data
        self.sectionHeader = { sectionHeader($0.value) }
        self.sectionFooter = { sectionFooter($0.value) }
        self.rowContent = { rowContent($0.value) }
    }
    
    public init<_SectionModel: Hashable, _Item: Hashable>(
        _ data: [ListSection<_SectionModel, _Item>],
        sectionHeader: @escaping (_SectionModel) -> SectionHeader,
        sectionFooter: @escaping (_SectionModel) -> SectionFooter,
        rowContent: @escaping (_Item) -> RowContent
    ) where Data == Array<ListSection<SectionModel, Item>>, SectionModel == HashIdentifiableValue<_SectionModel>, Item == HashIdentifiableValue<_Item> {
        self.data = data.map({ .init(model: .init($0.model), items: $0.items.map(HashIdentifiableValue.init)) })
        self.sectionHeader = { sectionHeader($0.value) }
        self.sectionFooter = { sectionFooter($0.value) }
        self.rowContent = { rowContent($0.value) }
    }
}

extension CollectionView where Data: RangeReplaceableCollection, SectionModel == Never, SectionHeader == Never, SectionFooter == Never {
    public init<Items: RandomAccessCollection>(
        _ items: Items,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent
    ) where Items.Element == Item {
        var data = Data.init()
        
        data.append(.init(items: items))
        
        self.init(
            data,
            sectionHeader: Never.produce,
            sectionFooter: Never.produce,
            rowContent: rowContent
        )
    }
}

extension CollectionView where Data == Array<ListSection<SectionModel, Item>>, SectionModel == Never, SectionHeader == Never, SectionFooter == Never {
    public init<Items: RandomAccessCollection>(
        _ items: Items,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent
    ) where Items.Element == Item {
        self.init(
            [.init(items: items)],
            sectionHeader: Never.produce,
            sectionFooter: Never.produce,
            rowContent: rowContent
        )
    }
}

// MARK: - API -

extension CollectionView {
    public func onOffsetChange(_ body: @escaping (Offset) -> ()) -> Self {
        then({ $0.scrollViewConfiguration.onOffsetChange = body })
    }
}

@available(tvOS, unavailable)
extension CollectionView {
    public func onRefresh(_ body: @escaping () -> Void) -> Self {
        then({ $0.scrollViewConfiguration.onRefresh = body })
    }
    
    public func isRefreshing(_ isRefreshing: Bool) -> Self {
        then({ $0.scrollViewConfiguration.isRefreshing = isRefreshing })
    }
}

#endif
