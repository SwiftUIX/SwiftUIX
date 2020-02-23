//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public class UIHostingTableViewController<Data: RandomAccessCollection, RowContent: View>: UITableViewController where Data.Element: Identifiable {
    var data: Data
    var rowContent: (Data.Element) -> RowContent
    var scrollViewConfiguration = CocoaScrollViewConfiguration<AnyView>() {
        didSet {
            #if os(iOS) || targetEnvironment(macCatalyst)
            scrollViewConfiguration.setupRefreshControl = {
                $0.addTarget(
                    self,
                    action: #selector(self.refreshChanged),
                    for: .valueChanged
                )
            }
            #endif
            
            tableView?.configure(with: scrollViewConfiguration)
        }
    }
    
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
    
    override public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewConfiguration.onOffsetChange(
            scrollView.contentOffset(forContentType: AnyView.self)
        )
    }
    
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
    
    @available(tvOS, unavailable)
    @objc public func refreshChanged(_ control: UIRefreshControl) {
        control.refreshChanged(with: scrollViewConfiguration)
    }
}

#endif
