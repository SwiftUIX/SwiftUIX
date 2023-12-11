//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import Swift
import SwiftUI

final class _PlatformTableView<Configuration: _CocoaListConfigurationType>: NSTableView {
    override func noteHeightOfRows(withIndexesChanged indexSet: IndexSet) {
        super.noteHeightOfRows(withIndexesChanged: indexSet)
    }
}

@_spi(Internal)
open class _PlatformTableViewContainer<Configuration: _CocoaListConfigurationType>: NSScrollView {
    var _coordinator: _CocoaList<Configuration>.Coordinator!
    
    var coordinator: _CocoaList<Configuration>.Coordinator {
        _coordinator!
    }
    
    private var _tableView: _PlatformTableView<Configuration> = {
        let tableView = _PlatformTableView<Configuration>()
        
        tableView.headerView = nil
        tableView.usesAutomaticRowHeights = true
        tableView.backgroundColor = .clear
        tableView.selectionHighlightStyle = .none

        return tableView
    }()
    
    private var _latestTableViewFrame: NSRect?
        
    private var _tableViewFrameObserver: NSObjectProtocol?
    
    var tableView: _PlatformTableView<Configuration> {
        _tableView
    }

    init(
        coordinator: _CocoaList<Configuration>.Coordinator
    ) {
        self._coordinator = coordinator
        
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
                        
        self.coordinator.tableViewContainer = self
        
        _latestTableViewFrame = _tableView.frame

        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "SwiftUIX"))
      
        column.title = ""
        
        tableView.addTableColumn(column)
        
        tableView.style = .plain
        tableView.dataSource = coordinator
        tableView.delegate = coordinator
        
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
