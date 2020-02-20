//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public class CocoaTableViewController<Data: RandomAccessCollection, RowContent: View>: UITableViewController where Data.Element: Identifiable {
    var data: Data
    var rowContent: (Data.Element) -> RowContent
    
    init(data: Data, rowContent: @escaping (Data.Element) -> RowContent) {
        self.data = data
        self.rowContent = rowContent
        
        super.init(style: .plain)
        
        tableView.register(CocoaHostingCell<RowContent>.self, forCellReuseIdentifier: .hostingCellIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: .hostingCellIdentifier, for: indexPath) as! CocoaHostingCell<RowContent>
        
        cell.rowContent = rowContent(data[data.index(data.startIndex, offsetBy: indexPath.row)])
        
        return cell
    }
}

#endif
