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
    private var _scrollOffsetCorrectionOnTableViewFrameChange: (() -> Void)?
    
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
    
    func reloadData(animated: Bool = true) {
        performEnforcingScrollOffsetBehavior(.maintainOnChangeOfContentSize, animated: animated) {
            tableView.reloadData()
        }
    }
    
    private func _setUp() {
        backgroundColor = .clear
        hasVerticalScroller = true
        hasHorizontalScroller = false
        autohidesScrollers = true
        
        self.coordinator.tableViewContainer = self
        
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "_SwiftUIX_PlatformTableViewContainer"))
        
        column.title = ""
        
        let contentView = _ClipView()
        
        contentView.parent = self
        
        self.contentView = contentView
        
        tableView.addTableColumn(column)
        
        tableView.style = .plain
        tableView.dataSource = coordinator
        tableView.delegate = coordinator
        
        documentView = _tableView
        
        _setUpTableViewObserver()
    }
    
    private func _performHidingScrollIndicators(_ operation: () -> Void) {
        let _hasVerticalScroller = hasVerticalScroller
        let _hasHorizontalScroller = hasHorizontalScroller
        
        hasVerticalScroller = false
        hasHorizontalScroller = false
        
        operation()
        
        hasVerticalScroller = _hasVerticalScroller
        hasHorizontalRuler = _hasHorizontalScroller
    }
    
    var _disableScrollFuckery: Bool = false
    
    override open func reflectScrolledClipView(_ cView: NSClipView) {
        guard !_disableScrollFuckery else {
            return
        }
        
        super.reflectScrolledClipView(cView)
    }
    
    func performEnforcingScrollOffsetBehavior(
        _ behavior: ScrollContentOffsetBehavior,
        animated: Bool,
        _ update: () -> Void
    ) {
        let savedScrollPosition = saveScrollOffset()
        
        _disableScrollFuckery = true
        update()
        _disableScrollFuckery = false
        
        self.restoreScrollOffset(to: savedScrollPosition)
        
        DispatchQueue.main.async {
            self.restoreScrollOffset(to: savedScrollPosition)
        }
    }
    
    func _performEnforcingScrollOffsetBehavior(
        _ behavior: ScrollContentOffsetBehavior,
        animated: Bool,
        _ update: () -> Void
    ) {
        guard behavior == .maintainOnChangeOfContentSize else {
            assertionFailure("unimplemented")
            
            return
        }
        
        let verticalScrollPosition = self.verticalScrollPosition
        let beforeContentOffset = contentOffset
        let beforeContentSize = contentSize
        
        update()
        
        if self.verticalScrollPosition != verticalScrollPosition {
            self.verticalScrollPosition = verticalScrollPosition
        }
        
        var corrected: Bool = false
        
        _scrollOffsetCorrectionOnTableViewFrameChange = {
            guard !corrected else {
                return
            }
            
            if self.verticalScrollPosition != verticalScrollPosition {
                self.verticalScrollPosition = verticalScrollPosition
                
                DispatchQueue.main.async {
                    self.verticalScrollPosition = verticalScrollPosition
                }
                
                DispatchQueue.main.async {
                    self.verticalScrollPosition = verticalScrollPosition
                }
            }
            
            defer {
                corrected = true
            }
            
            let afterContentSize = self.contentSize
            
            guard afterContentSize != beforeContentSize else {
                if self.contentOffset != beforeContentOffset {
                    self.contentOffset = beforeContentOffset
                }
                
                return
            }
            
            var deltaX = self.contentOffset.x + (afterContentSize.width - beforeContentSize.width)
            var deltaY = self.contentOffset.y + (afterContentSize.height - beforeContentSize.height)
            
            deltaX = beforeContentSize.width == 0 ? 0 : max(0, deltaX)
            deltaY = beforeContentSize.height == 0 ? 0 : max(0, deltaY)
            
            let newOffset = CGPoint(
                x: self.contentOffset.x + deltaX,
                y: self.contentOffset.y + deltaY
            )
            
            if self.contentOffset != newOffset {
                self.contentOffset = newOffset
            } else if self.contentOffset != beforeContentOffset {
                self.contentOffset = beforeContentOffset
            }
        }
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
        
        defer {
            _latestTableViewFrame = _tableView.frame
        }
        
        _performHidingScrollIndicators {
            _scrollOffsetCorrectionOnTableViewFrameChange?()
            _scrollOffsetCorrectionOnTableViewFrameChange = nil
        }
        
        /*if _latestTableViewFrame?.maxY == _tableView.visibleRect.maxY {
         scrollTo(.bottom)
         }*/
    }
    
    class _ClipView: NSClipView {
        var parent: _PlatformTableViewContainer!
        
        override func scroll(_ point: NSPoint) {
            guard !parent._disableScrollFuckery else {
                return
            }
            
            super.scroll(point)
        }
        
        override func awakeFromNib() {
            super.awakeFromNib()
        }
        
        override func viewBoundsChanged(_ notification: Notification) {
            super.viewBoundsChanged(notification)
        }
        
        override func setBoundsOrigin(_ newOrigin: NSPoint) {
            guard !parent._disableScrollFuckery else {
                return
            }
            
            super.setBoundsOrigin(newOrigin)
        }
        
        override func constrainBoundsRect(_ proposedBounds: NSRect) -> NSRect {
            return super.constrainBoundsRect(proposedBounds)
        }
    }
}

extension NSScrollView {
    func saveScrollOffset() -> NSPoint {
        guard let documentView = self.documentView else { return NSZeroPoint }
        let documentVisibleRect = documentView.visibleRect
        let savedRelativeScrollPosition = NSPoint(
            x: documentVisibleRect.minX,
            y: documentVisibleRect.maxY - bounds.height
        )
        return savedRelativeScrollPosition
    }
    
    func restoreScrollOffset(to savedRelativeScrollPosition: NSPoint) {
        _withoutAppKitOrUIKitAnimation {
            if let documentView = self.documentView {
                let newScrollOrigin = NSPoint(
                    x: savedRelativeScrollPosition.x,
                    y: documentView.bounds.maxY - bounds.height - savedRelativeScrollPosition.y
                )
                self.contentView.setBoundsOrigin(newScrollOrigin)
            }
        }
    }
}

#endif
