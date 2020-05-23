//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CocoaList<SectionModel: Identifiable, Item: Identifiable, Data: RandomAccessCollection, SectionHeader: View, SectionFooter: View, RowContent: View>: UIViewControllerRepresentable where Data.Element == ListSection<SectionModel, Item> {
    public typealias Offset = ScrollView<AnyView>.ContentOffset
    public typealias UIViewControllerType = UIHostingTableViewController<SectionModel, Item, Data, SectionHeader, SectionFooter, RowContent>
    
    @usableFromInline
    let data: Data
    @usableFromInline
    let sectionHeader: (SectionModel) -> SectionHeader
    @usableFromInline
    let sectionFooter: (SectionModel) -> SectionFooter
    @usableFromInline
    let rowContent: (Item) -> RowContent
    
    @usableFromInline
    var style: UITableView.Style = .plain
    
    #if !os(tvOS)
    @usableFromInline
    var separatorStyle: UITableViewCell.SeparatorStyle = .singleLine
    #endif
    
    @usableFromInline
    var scrollViewConfiguration = CocoaScrollViewConfiguration<AnyView>()
    
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
            style: style,
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
        
        uiViewController.initialContentAlignment = context.environment.initialContentAlignment
        
        uiViewController.scrollViewConfiguration = scrollViewConfiguration.updating(from: context.environment)

        #if !os(tvOS)
        uiViewController.tableView.separatorStyle = separatorStyle
        #endif
        
        uiViewController.reloadData()
    }
}

extension CocoaList {
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

extension CocoaList where Data: RangeReplaceableCollection, SectionModel == Never, SectionHeader == Never, SectionFooter == Never {
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

extension CocoaList where Data == Array<ListSection<SectionModel, Item>>, SectionModel == Never, SectionHeader == Never, SectionFooter == Never {
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

extension CocoaList {
    @inlinable
    public func listStyle(_ style: UITableView.Style) -> Self {
        then({ $0.style = style })
    }
    
    #if !os(tvOS)
    @inlinable
    public func listSeparatorStyle(_ separatorStyle: UITableViewCell.SeparatorStyle) -> Self {
        then({ $0.separatorStyle = separatorStyle })
    }
    #endif
}

extension CocoaList {
    @inlinable
    public func onOffsetChange(_ body: @escaping (Offset) -> ()) -> Self {
        then({ $0.scrollViewConfiguration.onOffsetChange = body })
    }
    
    @inlinable
    public func contentOffset(_ contentOffset: Binding<CGPoint>) -> Self {
        then({ $0.scrollViewConfiguration.contentOffset = contentOffset })
    }
}

@available(tvOS, unavailable)
extension CocoaList {
    @inlinable
    public func onRefresh(_ body: @escaping () -> Void) -> Self {
        then({ $0.scrollViewConfiguration.onRefresh = body })
    }
    
    @inlinable
    public func isRefreshing(_ isRefreshing: Bool) -> Self {
        then({ $0.scrollViewConfiguration.isRefreshing = isRefreshing })
    }
}

#endif
