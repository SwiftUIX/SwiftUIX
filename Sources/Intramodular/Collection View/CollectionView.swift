//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CocoaCollectionView<SectionModel: Identifiable, Item: Identifiable, Data: RandomAccessCollection, SectionHeader: View, SectionFooter: View, RowContent: View>: UIViewRepresentable where Data.Element == ListSection<SectionModel, Item> {
    public typealias Offset = ScrollView<AnyView>.ContentOffset
    public typealias UIViewType = UIHostingCollectionView<SectionModel, Item, Data, SectionHeader, SectionFooter, RowContent>
    
    private let data: Data
    private let sectionHeader: (SectionModel) -> SectionHeader
    private let sectionFooter: (SectionModel) -> SectionFooter
    private let rowContent: (Item) -> RowContent
    
    private var scrollViewConfiguration = CocoaScrollViewConfiguration<AnyView>()
    
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
    
    public func makeUIView(context: Context) -> UIViewType {
        .init(
            data,
            collectionViewLayout: UICollectionViewFlowLayout().then {
                $0.itemSize = UICollectionViewFlowLayout.automaticSize
                $0.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            },
            sectionHeader: sectionHeader,
            sectionFooter: sectionFooter,
            rowContent: rowContent
        )
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        let isDirty = !uiView.data.isIdentical(to: data)
        
        if isDirty {
            uiView._isDataDirty = true
        }
        
        uiView.data = data
        uiView.sectionHeader = sectionHeader
        uiView.sectionFooter = sectionFooter
        uiView.rowContent = rowContent
        
        uiView.isScrollEnabled = isScrollEnabled
        
        uiView.configure(with: scrollViewConfiguration)
        
        uiView.reloadData()
    }
}

extension CocoaCollectionView {
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

extension CocoaCollectionView where Data: RangeReplaceableCollection, SectionModel == Never, SectionHeader == Never, SectionFooter == Never {
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

extension CocoaCollectionView where Data == Array<ListSection<SectionModel, Item>>, SectionModel == Never, SectionHeader == Never, SectionFooter == Never {
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

extension CocoaCollectionView {
    public func onOffsetChange(_ body: @escaping (Offset) -> ()) -> Self {
        then({ $0.scrollViewConfiguration.onOffsetChange = body })
    }
}

@available(tvOS, unavailable)
extension CocoaCollectionView {
    public func onRefresh(_ body: @escaping () -> Void) -> Self {
        then({ $0.scrollViewConfiguration.onRefresh = body })
    }
    
    public func isRefreshing(_ isRefreshing: Bool) -> Self {
        then({ $0.scrollViewConfiguration.isRefreshing = isRefreshing })
    }
}

#endif
