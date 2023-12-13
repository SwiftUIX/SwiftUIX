//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import Swift
import SwiftUI

final class _PlatformTableView<Configuration: _CocoaListConfigurationType>: NSTableView {
    private let heightUpdatesQueue = DispatchQueue.main._debounce()
    
    func noteHeightOfRowsChanged() {
        heightUpdatesQueue.schedule {
            self.reloadData()
            
            DispatchQueue.main.async {
                NSAnimationContext.beginGrouping()
                NSAnimationContext.current.duration = 0
                let entireTableView: IndexSet = .init(0..<self.numberOfRows)
                self.noteHeightOfRows(withIndexesChanged: entireTableView)
                NSAnimationContext.endGrouping()
            }
        }
    }
    
    override func noteHeightOfRows(
        withIndexesChanged indexSet: IndexSet
    ) {
        super.noteHeightOfRows(withIndexesChanged: indexSet)
    }
    
    override func resizeSubviews(
        withOldSize oldSize: NSSize
    ) {
        super.resizeSubviews(withOldSize: oldSize)
    }
}

@_spi(Internal)
open class _PlatformTableViewContainer<Configuration: _CocoaListConfigurationType>: NSScrollView {
    private var _coordinator: _CocoaList<Configuration>.Coordinator!
    
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
        
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "_SwiftUIX_PlatformTableViewContainer"))
      
        column.title = ""
        
        tableView.addTableColumn(column)
        
        tableView.style = .plain
        tableView.dataSource = coordinator
        tableView.delegate = coordinator
        
        documentView = _tableView
        
       // _setUpTableViewObserver()
    }
    
    private func _setUpTableViewObserver() {
        tableView.postsBoundsChangedNotifications = true

        _tableViewFrameObserver = NotificationCenter.default.addObserver(
            forName: NSView.frameDidChangeNotification,
            object: _tableView,
            queue: .main,
            using: { [weak self] _ in
                self?._observeTableViewFrameChange()
            }
        )
    }
    
    func _observeTableViewFrameChange() {
        guard _latestTableViewFrame != nil else {
            _latestTableViewFrame = _tableView.frame
            
            return
        }
        
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
