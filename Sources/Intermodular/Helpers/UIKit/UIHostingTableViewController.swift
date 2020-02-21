//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public class UIHostingTableViewController<Data: RandomAccessCollection, RowContent: View>: UITableViewController where Data.Element: Identifiable {
    var data: Data
    var rowContent: (Data.Element) -> RowContent
    
    init(data: Data, rowContent: @escaping (Data.Element) -> RowContent) {
        self.data = data
        self.rowContent = rowContent
        
        super.init(style: .plain)

        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.register(UIHostingTableViewCell<RowContent>.self, forCellReuseIdentifier: .hostingCellIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Data Source -
    
    override public func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        data.count
    }
    
    override public func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .hostingCellIdentifier, for: indexPath) as! UIHostingTableViewCell<RowContent>
        
        cell.content = rowContent(data[data.index(data.startIndex, offsetBy: indexPath.row)])
        
        return cell
    }
    
    // MARK: - Delegate -
    
    override public func tableView(
        _ tableView: UITableView,
        shouldHighlightRowAt indexPath: IndexPath
    ) -> Bool {
        false
    }
    
    override public func tableView(
        _ tableView: UITableView,
        willSelectRowAt indexPath: IndexPath
    ) -> IndexPath? {
        nil
    }
}

#endif
