//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import Swift
import SwiftUI

@_spi(Internal)
open class _PlatformTableView<Configuration: _CocoaListConfigurationType>: NSScrollView {
    var coordinator: Coordinator!
    
    private var _tableView = NSTableView()
    private var _lastTableViewFrame: NSRect?
        
    private var frameDidChangeNotificationHandle: NSObjectProtocol?
    
    public var tableView: NSTableView {
        _tableView
    }

    init(coordinator: Coordinator) {
        self.coordinator = coordinator
        
        super.init(frame: .zero)
        
        _setUp()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func _setUp() {
        backgroundColor = .clear
        hasVerticalScroller = true
        hasHorizontalScroller = false
        autohidesScrollers = true
        
        _tableView.headerView = nil
        _tableView.usesAutomaticRowHeights = true
        _tableView.backgroundColor = .clear
        _tableView.intercellSpacing = NSSize(width: 0, height: 12)
        _tableView.selectionHighlightStyle = .none
        
        _lastTableViewFrame = _tableView.frame
        
        _tableView.postsBoundsChangedNotifications = true
        
        frameDidChangeNotificationHandle = NotificationCenter.default.addObserver(
            forName: NSView.frameDidChangeNotification,
            object: _tableView,
            queue: .main,
            using: {
                [weak self] _ in
                self?.tableViewFrameDidChange()
            }
        )
        
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "SwiftUIX"))
        column.title = ""
        _tableView.addTableColumn(column)
        
        _tableView.dataSource = coordinator
        _tableView.delegate = coordinator
        
        documentView = _tableView
    }
    
    func tableViewFrameDidChange() {
        if _lastTableViewFrame?.maxY == _tableView.visibleRect.maxY {
            _tableView.scrollToEndOfDocument(nil)
        }
        
        _lastTableViewFrame = _tableView.frame
    }
    
    func updateTable() {
        _tableView.reloadData()
        _tableView.scrollToEndOfDocument(nil)
    }
}

extension _PlatformTableView {
    class Coordinator: NSObject, NSTableViewDataSource, NSTableViewDelegate {
        public var configuration: Configuration
        
        public init(configuration: Configuration) {
            self.configuration = configuration
        }
        
        func numberOfRows(
            in tableView: NSTableView
        ) -> Int {
            configuration.data.payload.map(\.items.count).reduce(into: 0, +=)
        }
        
        func tableView(
            _ tableView: NSTableView,
            objectValueFor tableColumn: NSTableColumn?,
            row: Int
        ) -> Any? {
            return configuration.data.payload.first![row]
        }
        
        func tableView(
            _ tableView: NSTableView,
            viewFor tableColumn: NSTableColumn?,
            row: Int
        ) -> NSView? {
            let identifier = NSUserInterfaceItemIdentifier("messageTableCellView")
            let cellView: _PlatformTableCellView<Configuration>
            let item = configuration.data.payload.first![row]
            let itemIdentifier = item[keyPath: configuration.data.itemID]

            if let _cellView = tableView.makeView(
                withIdentifier: identifier,
                owner: self
            ) as? _PlatformTableCellView<Configuration> {
                cellView = _cellView
            } else {
                let _cellView = _PlatformTableCellView<Configuration>()
                
                _cellView.identifier = identifier
                
                cellView = _cellView
            }
            
            cellView.hostingView.rootView.item = itemIdentifier
            cellView.hostingView.rootView.base = configuration.viewProvider.rowContent(item)
            
            return cellView
        }
        
        func tableView(
            _ tableView: NSTableView,
            didAdd rowView: NSTableRowView,
            forRow row: Int
        ) {
            rowView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
}

#endif
