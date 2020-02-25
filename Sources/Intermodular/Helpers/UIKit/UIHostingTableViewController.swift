//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public class UIHostingTableViewController<SectionModel: Identifiable, Item: Identifiable, Data: RandomAccessCollection, SectionHeader: View, SectionFooter: View, RowContent: View>: UITableViewController where Data.Element == ListSection<SectionModel, Item> {
    var data: Data
    var sectionHeader: (SectionModel) -> SectionHeader
    var sectionFooter: (SectionModel) -> SectionFooter
    var rowContent: (Item) -> RowContent
    
    var _prototypeCell: UIHostingTableViewCell<RowContent>?
    
    var prototypeCell: UIHostingTableViewCell<RowContent> {
        guard let _prototypeCell = _prototypeCell else {
            self._prototypeCell = .some(tableView.dequeueReusableCell(withIdentifier: .hostingTableViewCellIdentifier) as! UIHostingTableViewCell<RowContent>)
            
            return self._prototypeCell!
        }
        
        return _prototypeCell
    }
    
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
    
    var isInitialContentAlignmentSet: Bool = false
    
    public init(
        _ data: Data,
        style: UITableView.Style,
        sectionHeader: @escaping (SectionModel) -> SectionHeader,
        sectionFooter: @escaping (SectionModel) -> SectionFooter,
        rowContent: @escaping (Item) -> RowContent
    ) {
        self.data = data
        self.sectionHeader = sectionHeader
        self.sectionFooter = sectionFooter
        self.rowContent = rowContent
        
        super.init(style: style)
        
        tableView.backgroundView = .init()
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionFooterHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.sectionFooterHeight = UITableView.automaticDimension
        
        tableView.register(UIHostingTableViewHeaderFooterView<SectionHeader>.self, forHeaderFooterViewReuseIdentifier: .hostingTableViewHeaderViewIdentifier)
        tableView.register(UIHostingTableViewHeaderFooterView<SectionFooter>.self, forHeaderFooterViewReuseIdentifier: .hostingTableViewFooterViewIdentifier)
        tableView.register(UIHostingTableViewCell<RowContent>.self, forCellReuseIdentifier: .hostingTableViewCellIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func numberOfSections(in tableView: UITableView) -> Int {
        data.count
    }
    
    override public func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        data[data.index(data.startIndex, offsetBy: section)].items.count
    }
    
    override public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard SectionHeader.self != Never.self else {
            return nil
        }
        
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: .hostingTableViewHeaderViewIdentifier) as! UIHostingTableViewHeaderFooterView<SectionHeader>
        
        view.backgroundColor = .clear // FIXME
        view.backgroundView = .init() // FIXME
        view.layoutMargins = .zero // FIXME
        
        view.content = sectionHeader(data[data.index(data.startIndex, offsetBy: section)].model)
        
        return view
    }
    
    override public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard SectionFooter.self != Never.self else {
            return nil
        }
        
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: .hostingTableViewFooterViewIdentifier) as! UIHostingTableViewHeaderFooterView<SectionFooter>
        
        view.backgroundColor = .clear // FIXME
        view.backgroundView = .init() // FIXME
        view.layoutMargins = .zero // FIXME
        
        view.content = sectionFooter(data[data.index(data.startIndex, offsetBy: section)].model)
        
        return view
    }
    
    override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        prototypeCell.content = rowContent(data[indexPath])
        
        let height = prototypeCell
            .contentView
            .systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            .height
        
        return max(1, height)
    }
    
    override public func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .hostingTableViewCellIdentifier) as! UIHostingTableViewCell<RowContent>
        
        cell.content = rowContent(data[indexPath])
        
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
