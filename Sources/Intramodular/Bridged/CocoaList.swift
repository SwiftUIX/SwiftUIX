//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CocoaList<Data: RandomAccessCollection, RowContent: View>: UIViewControllerRepresentable where Data.Element: Identifiable {
    public typealias Offset = ScrollView<AnyView>.Offset
    public typealias UIViewControllerType = UIHostingTableViewController<Data, RowContent>
    
    private let data: Data
    private let rowContent: (Data.Element) -> RowContent
    private var scrollViewConfiguration = CocoaScrollViewConfiguration<AnyView>()
    
    public init(_ data: Data, rowContent: @escaping (Data.Element) -> RowContent) {
        self.data = data
        self.rowContent = rowContent
    }
    
    public func makeUIViewController(context: Context) -> UIViewControllerType {
        .init(data: data, rowContent: rowContent)
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController.data = data
        uiViewController.rowContent = rowContent
        uiViewController.scrollViewConfiguration = scrollViewConfiguration
        
        uiViewController.tableView.reloadData()
    }
}

extension CocoaList {
    public func onOffsetChange(_ body: @escaping (Offset) -> ()) -> Self {
        then({ $0.scrollViewConfiguration.onOffsetChange = body })
    }
}

@available(tvOS, unavailable)
extension CocoaList {
    public func onRefresh(_ body: @escaping () -> Void) -> Self {
        then({ $0.scrollViewConfiguration.onRefresh = body })
    }
    
    public func isRefreshing(_ isRefreshing: Bool) -> Self {
        then({ $0.scrollViewConfiguration.isRefreshing = isRefreshing })
    }
}

#endif
