//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CocoaList<
    SectionModel: Identifiable,
    ItemType: Identifiable,
    Data: RandomAccessCollection,
    SectionHeader: View,
    SectionFooter: View,
    RowContent: View
>: UIViewControllerRepresentable where Data.Element == ListSection<SectionModel, ItemType> {
    public typealias Offset = ScrollView<AnyView>.ContentOffset
    public typealias UIViewControllerType = UIHostingTableViewController<SectionModel, ItemType, Data, SectionHeader, SectionFooter, RowContent>
    
    @usableFromInline
    let data: Data
    @usableFromInline
    let sectionHeader: (SectionModel) -> SectionHeader
    @usableFromInline
    let sectionFooter: (SectionModel) -> SectionFooter
    @usableFromInline
    let rowContent: (ItemType) -> RowContent
    
    @usableFromInline
    var style: UITableView.Style = .plain

    @usableFromInline
    var tableHeader: UIView? = nil
    @usableFromInline
    var tableFooter: UIView? = nil

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
        rowContent: @escaping (ItemType) -> RowContent
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

        uiViewController.tableView.tableHeaderView = tableHeader
        uiViewController.tableView.tableFooterView = tableFooter

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
    ) where ItemType == HashIdentifiableValue<_Item> {
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
    ) where SectionModel == HashIdentifiableValue<_SectionModel>, ItemType == HashIdentifiableValue<_Item> {
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
    ) where Data == Array<ListSection<SectionModel, ItemType>>, SectionModel == HashIdentifiableValue<_SectionModel>, ItemType == HashIdentifiableValue<_Item> {
        self.data = data.map({ .init(model: .init($0.model), data: $0.data.map(HashIdentifiableValue.init)) })
        self.sectionHeader = { sectionHeader($0.value) }
        self.sectionFooter = { sectionFooter($0.value) }
        self.rowContent = { rowContent($0.value) }
    }
}

extension CocoaList where Data: RangeReplaceableCollection, SectionModel == KeyPathHashIdentifiableValue<Int, Int>, SectionHeader == Never, SectionFooter == Never {
    public init<Items: RandomAccessCollection>(
        _ items: Items,
        @ViewBuilder rowContent: @escaping (ItemType) -> RowContent
    ) where Items.Element == ItemType {
        var data = Data.init()
        
        data.append(.init(model: KeyPathHashIdentifiableValue(value: 0, keyPath: \.self), items: items))
        
        self.init(
            data,
            sectionHeader: Never.produce,
            sectionFooter: Never.produce,
            rowContent: rowContent
        )
    }
    
    public init<Items: RandomAccessCollection>(
        @ViewBuilder content: @escaping () -> ForEach<Items, ItemType.ID, RowContent>
    ) where Items.Element == ItemType, Data == Array<ListSection<SectionModel, ItemType>> {
        var data = Data.init()
        
        let content = content()
        
        data.append(.init(model: KeyPathHashIdentifiableValue(value: 0, keyPath: \.self), items: content.data))
        
        self.init(
            data,
            sectionHeader: Never.produce,
            sectionFooter: Never.produce,
            rowContent: content.content
        )
    }
}

extension CocoaList where Data == Array<ListSection<SectionModel, ItemType>>, SectionModel == KeyPathHashIdentifiableValue<Int, Int>, SectionHeader == Never, SectionFooter == Never {
    public init<Items: RandomAccessCollection>(
        _ items: Items,
        @ViewBuilder rowContent: @escaping (ItemType) -> RowContent
    ) where Items.Element == ItemType {
        self.init(
            [.init(model: KeyPathHashIdentifiableValue(value: 0, keyPath: \.self), items: items)],
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

    @inlinable
    public func tableHeader<TableHeader: View>(_ tableHeader: TableHeader) -> Self {
        then {
            let view = UIHostingView(rootView: tableHeader)
            view.frame = CGRect(origin: .zero, size: view.sizeThatFits(.greatestFiniteSize))
            $0.tableHeader = view
        }
    }

    @inlinable
    public func tableFooter<TableHeader: View>(_ tableFooter: TableHeader) -> Self {
        then {
            let view = UIHostingView(rootView: tableFooter)
            view.frame = CGRect(origin: .zero, size: view.sizeThatFits(.greatestFiniteSize))
            $0.tableFooter = view
        }
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
    public func alwaysBounceVertical(_ alwaysBounceVertical: Bool) -> Self {
        then({ $0.scrollViewConfiguration.alwaysBounceVertical = alwaysBounceVertical })
    }

    @inlinable
    public func alwaysBounceHorizontal(_ alwaysBounceHorizontal: Bool) -> Self {
        then({ $0.scrollViewConfiguration.alwaysBounceHorizontal = alwaysBounceHorizontal })
    }

    @inlinable
    public func onOffsetChange(_ body: @escaping (Offset) -> ()) -> Self {
        then({ $0.scrollViewConfiguration.onOffsetChange = body })
    }
    
    @inlinable
    public func contentInset(_ contentInset: UIEdgeInsets) -> Self {
        then({ $0.scrollViewConfiguration.contentInset = contentInset })
    }
    
    @inlinable
    public func contentInset(_ insets: EdgeInsets) -> Self {
        contentInset(
            .init(
                top: insets.top,
                left: insets.leading,
                bottom: insets.bottom,
                right: insets.trailing
            )
        )
    }
    
    @inlinable
    public func contentInset(
        _ edges: Edge.Set = .all,
        _ length: CGFloat = 0
    ) -> Self {
        var insets = self.scrollViewConfiguration.contentInset
        
        if edges.contains(.top) {
            insets.top += length
        }
        
        if edges.contains(.leading) {
            insets.left += length
        }
        
        if edges.contains(.bottom) {
            insets.bottom += length
        }
        
        if edges.contains(.trailing) {
            insets.right += length
        }
        
        return self.contentInset(insets)
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
    
    @inlinable
    public func refreshControlTintColor(_ color: UIColor?) -> Self {
        then({ $0.scrollViewConfiguration.refreshControlTintColor = color })
    }
}

#endif
