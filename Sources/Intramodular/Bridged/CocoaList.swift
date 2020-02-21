//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CocoaList<Data: RandomAccessCollection, RowContent: View>: UIViewControllerRepresentable where Data.Element: Identifiable {
    public typealias UIViewControllerType = UIHostingTableViewController<Data, RowContent>
    
    private let data: Data
    private let rowContent: (Data.Element) -> RowContent
    
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
        
        uiViewController.tableView.reloadData()
    }
}

#endif
