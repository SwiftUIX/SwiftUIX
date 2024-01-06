//
// Copyright (c) Vatsal Manot
//

import SwiftUI

#if os(macOS)

@_spi(Internal)
open class _PlatformTableViewContainer<Configuration: _CocoaListConfigurationType>: NSScrollView {
    private var _coordinator: _CocoaList<Configuration>.Coordinator!
    
    var _disableScrollFuckery: Bool = false

    var coordinator: _CocoaList<Configuration>.Coordinator {
        _coordinator!
    }
    
    private lazy var _tableView: _PlatformTableView<Configuration> = {
        let tableView = _PlatformTableView<Configuration>(listRepresentable: self.coordinator)
        
        tableView.headerView = nil
        tableView.backgroundColor = .clear
        tableView.selectionHighlightStyle = .none
        tableView.style = .plain
        tableView.usesAutomaticRowHeights = true
        
        return tableView
    }()
    
    private var _latestTableViewFrame: NSRect?
    
    private var _tableViewFrameObserver: NSObjectProtocol?
    private var _scrollOffsetCorrectionOnTableViewFrameChange: (() -> Void)?
    
    func representableDidUpdate(
        _ view: _CocoaList<Configuration>,
        context: any _AppKitOrUIKitViewRepresentableContext
    ) {
        
    }

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
        performEnforcingScrollOffsetBehavior([], animated: animated) {
            tableView.reloadData()
            
            invalidateEntireRowHeightCache()
        }
    }
    
    private func _setUp() {
        backgroundColor = .clear
        hasVerticalScroller = true
        hasHorizontalScroller = false
        autohidesScrollers = true
        automaticallyAdjustsContentInsets = false
        
        self.coordinator.tableViewContainer = self
        
        let column = NSTableColumn(
            identifier: NSUserInterfaceItemIdentifier(rawValue: "_SwiftUIX_PlatformTableViewContainer")
        )
        
        column.title = ""
        
        let contentView = _ClipView()
        
        contentView.parent = self
        
        self.contentView = contentView
        
        tableView.addTableColumn(column)
        
        tableView.dataSource = coordinator
        tableView.delegate = coordinator
        
        documentView = _tableView
        
        _setUpTableViewObserver()
    }
            
    func performEnforcingScrollOffsetBehavior(
        _ behavior: ScrollContentOffsetBehavior,
        animated: Bool,
        _ operation: () -> Void
    ) {
        guard behavior == .maintainOnChangeOfBounds else {
            assert(behavior == []) // other behaviors aren't supported right now
            
            operation()
            
            return
        }
        
        NSAnimationContext.runAnimationGroup { context in
            if visibleRect.origin.y > 0 {
                context.duration = 0
            }
            
            let SwiftUIX_scrollOffset = self.contentOffset
            let oldScrollOffset = tableView.visibleRect.origin
            let previousHeight = tableView.bounds.size.height
            
            operation()
            
            guard !isContentWithinBounds else {
                return
            }
            
            let SwiftUIX_newScrollOffset = self.contentOffset
            
            if SwiftUIX_scrollOffset == SwiftUIX_newScrollOffset {
                return
            }
            
            var newScrollOffset = oldScrollOffset
            
            newScrollOffset.y += (tableView.bounds.size.height - previousHeight)
            
            if oldScrollOffset.y == 0 {
                self.contentOffset = oldScrollOffset
            } else if newScrollOffset.y > oldScrollOffset.y {
                self.contentOffset = newScrollOffset
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
        guard let oldFrame = _latestTableViewFrame else {
            _latestTableViewFrame = _tableView.frame
            
            return
        }
        
        guard oldFrame.size.isRegularAndNonZero else {
            return
        }
        
        let newFrame = _tableView.frame
        
        _latestTableViewFrame = newFrame
                
        _performHidingScrollIndicators {
            _scrollOffsetCorrectionOnTableViewFrameChange?()
            _scrollOffsetCorrectionOnTableViewFrameChange = nil
        }
        
        /*if oldFrame.height != newFrame.height {
            if _latestTableViewFrame?.maxY == _tableView.visibleRect.maxY {
                scrollTo(.bottom)
            }
        }*/
    }
    
    private func _performHidingScrollIndicators(
        _ operation: () -> Void
    ) {
        let _hasVerticalScroller = hasVerticalScroller
        let _hasHorizontalScroller = hasHorizontalScroller
        
        hasVerticalScroller = false
        hasHorizontalScroller = false
        
        operation()
        
        hasVerticalScroller = _hasVerticalScroller
        hasHorizontalRuler = _hasHorizontalScroller
    }
}

// MARK: - Auxiliary

extension _PlatformTableViewContainer {
    class _ClipView: NSClipView {
        weak var parent: _PlatformTableViewContainer!
        
        override func scroll(_ point: NSPoint) {
            guard !parent._disableScrollFuckery else {
                return
            }
            
            super.scroll(point)
        }
        
        override func awakeFromNib() {
            super.awakeFromNib()
        }
        
        override func viewBoundsChanged(
            _ notification: Notification
        ) {
            super.viewBoundsChanged(notification)
        }
        
        override func setBoundsOrigin(_ newOrigin: NSPoint) {
            guard !parent._disableScrollFuckery else {
                return
            }
            
            super.setBoundsOrigin(newOrigin)
        }
        
        override func constrainBoundsRect(
            _ proposedBounds: NSRect
        ) -> NSRect {
             super.constrainBoundsRect(proposedBounds)
        }
    }
}

extension _PlatformTableViewContainer {
    func invalidateEntireRowHeightCache() {
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.duration = 0
        let entireTableView: IndexSet = .init(0 ..< self.tableView.numberOfRows)
        self.tableView.noteHeightOfRows(withIndexesChanged: entireTableView)
        NSAnimationContext.endGrouping()
    }
}

extension NSTableView {
    func performEnforcingScrollOffsetBehavior(
        _ behavior: ScrollContentOffsetBehavior,
        animated: Bool,
        operation update: () -> Void
    ) {
        NSAnimationContext.runAnimationGroup { context in
            if visibleRect.origin.y > 0 {
                context.duration = 0
            }
            
            let oldScrollOffset = visibleRect.origin
            let previousHeight = bounds.size.height
            
            update()
            
            var newScrollOffset = oldScrollOffset
            newScrollOffset.y += (bounds.size.height - previousHeight)
            
            if oldScrollOffset.y == 0 {
                scroll(oldScrollOffset)
            } else if newScrollOffset.y > oldScrollOffset.y {
                scroll(newScrollOffset)
            }
        }
    }
}

extension NSScrollView {
    fileprivate func saveScrollOffset() -> CGPoint {
        guard let documentView = self.documentView else {
            return .zero
        }
        
        let documentVisibleRect = documentView.visibleRect
        let savedRelativeScrollPosition = NSPoint(
            x: documentVisibleRect.minX,
            y: documentVisibleRect.maxY - bounds.height
        )
        
        return savedRelativeScrollPosition
    }
    
    fileprivate func restoreScrollOffset(
        to savedRelativeScrollPosition: NSPoint
    ) {
        guard let documentView = self.documentView else {
            return
        }
        
        _withoutAppKitOrUIKitAnimation {
            let newScrollOrigin = NSPoint(
                x: savedRelativeScrollPosition.x,
                y: documentView.bounds.maxY - bounds.height - savedRelativeScrollPosition.y
            )
            
            self.contentView.setBoundsOrigin(newScrollOrigin)
        }
    }
}

#endif
