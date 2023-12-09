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
    
    private var _tableView: NSTableView = {
        let tableView = NSTableView()
        
        tableView.headerView = nil
        tableView.usesAutomaticRowHeights = true
        tableView.backgroundColor = .clear
        tableView.intercellSpacing = NSSize(width: 0, height: 12)
        tableView.selectionHighlightStyle = .none

        return tableView
    }()
    
    private var _latestTableViewFrame: NSRect?
        
    private var _tableViewFrameObserver: NSObjectProtocol?
    
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
                        
        self.coordinator.tableView = tableView
        
        _latestTableViewFrame = _tableView.frame

        
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "SwiftUIX"))
      
        column.title = ""
        
        tableView.addTableColumn(column)
        
        tableView.style = .plain
        tableView.dataSource = coordinator
        tableView.delegate = coordinator
        
        self.scrollerInsets = .init(top: .zero, left: .zero, bottom: .zero, right: .zero)
        contentInsets = .init(top: .zero, left: .zero, bottom: .zero, right: .zero)
        documentView = _tableView
    }
    
    private func _setUpTableViewObserver() {
        _tableViewFrameObserver = NotificationCenter.default.addObserver(
            forName: NSView.frameDidChangeNotification,
            object: _tableView,
            queue: .main,
            using: { [weak self] _ in
                self?._observeTableViewFrameChange()
            }
        )
        
        tableView.postsBoundsChangedNotifications = true
    }
    
    func _observeTableViewFrameChange() {
        guard _latestTableViewFrame != _tableView.frame else {
            return
        }
        
        if _latestTableViewFrame?.maxY == _tableView.visibleRect.maxY {
            _tableView.scrollToEndOfDocument(nil)
        }
        
        _latestTableViewFrame = _tableView.frame
    }
}

#endif
