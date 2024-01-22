//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

@_spi(Internal) import _SwiftUIX
import AppKit
import Swift
import SwiftUI

extension _CocoaList: NSViewRepresentable {
    public typealias NSViewType = _PlatformTableViewContainer<Configuration>
    
    func makeNSView(
        context: Context
    ) -> NSViewType {
        context.coordinator.configuration = configuration

        let view = NSViewType(coordinator: context.coordinator)
        
        return view
    }
    
    func updateNSView(
        _ view: NSViewType,
        context: Context
    ) {
        func updateCocoaScrollProxy() {
            guard context.environment._cocoaScrollViewProxy.wrappedValue != nil else {
                return
            }
            
            let proxyBox = context.environment._cocoaScrollViewProxy
            
            if !(proxyBox.wrappedValue?.base === view) {
                DispatchQueue.main.async {
                    proxyBox.wrappedValue?.base = view
                }
            }
        }
        
        updateCocoaScrollProxy()
            
        context.coordinator.representableWillUpdate()
        context.coordinator.invalidationContext.transaction = context.transaction
        context.coordinator.configuration = configuration
        context.coordinator.representableDidUpdate()
        
        view.representableDidUpdate(self, context: context)
    }
    
    @MainActor
    public static func dismantleNSView(
        _ view: NSViewType,
        coordinator: Coordinator
    ) {
        coordinator.cache.invalidate()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(configuration: configuration)
    }
}

extension _CocoaList {
    enum StateFlag {
        case isFirstRun
        case dataChanged
        case didJustReload
        case isNSTableViewPreparingContent
        case isWithinSwiftUIUpdate
    }
    
    class InvalidationContext {
        var transaction = Transaction()
        var indexes: IndexSet = []
        
        init() {
            transaction.disableAnimations()
        }
    }
}

extension _CocoaList {
    class Coordinator: NSObject, NSTableViewDataSource, NSTableViewDelegate {        
        var stateFlags: Set<StateFlag> = []
        lazy var cache = _CocoaListCache<Configuration>(owner: self)
        var preferredScrollViewConfiguration: CocoaScrollViewConfiguration<AnyView> = nil
        
        var invalidationContext = InvalidationContext()
        
        private var scrollViewConfiguration: CocoaScrollViewConfiguration<AnyView> {
            var result = preferredScrollViewConfiguration
            if stateFlags.contains(.isFirstRun) {
                result.showsVerticalScrollIndicator = false
                result.showsHorizontalScrollIndicator = false
            }
            
            return result
        }
        
        public var configuration: Configuration {
            didSet {
                let reload = cache.update(configuration: configuration)
                
                if reload {
                    stateFlags.insert(.dataChanged)
                }
            }
        }
                
        weak var tableViewContainer: _PlatformTableViewContainer<Configuration>?
        
        var tableView: NSTableView? {
            tableViewContainer?.tableView
        }
        
        public init(configuration: Configuration) {
            self.configuration = configuration
            
            self.stateFlags.insert(.isFirstRun)
        }
        
        func representableWillUpdate() {
            stateFlags.insert(.isWithinSwiftUIUpdate)
        }
        
        func representableDidUpdate() {
            defer {
                stateFlags.remove(.isWithinSwiftUIUpdate)
            }
            
            guard let view = tableViewContainer else {
                return
            }
            
            defer {
                DispatchQueue.main.async {
                    self.stateFlags.remove(.isFirstRun)
                }
            }
            
            view.configure(with: scrollViewConfiguration)
            
            if self.stateFlags.contains(.dataChanged) {
                reload()
            }
                        
            if !stateFlags.contains(.didJustReload) && !stateFlags.contains(.dataChanged) {
                updateTableViewCells()
            }
            
            clearInvalidationContext()
        }
                
        // MARK: - NSTableViewDataSource
                
        func tableView(
            _ tableView: NSTableView,
            heightOfRow row: Int
        ) -> CGFloat {
            if let cache = cache[cheap: IndexPath(item: row, section: 0)] {
                if let height = cache.lastContentSize?.height {
                    return height
                }
            }
                        
            switch configuration.preferences.cell.sizingOptions {
                case .auto:
                    return NSTableCellView.automaticSize.height
                case .fixed(let width, let height):
                    assert(width == nil, "Fixed width is currently unsupported.")
                    
                    guard let height else {
                        return NSTableCellView.automaticSize.height
                    }
                    
                    return height
                case .custom(let height):
                    switch height {
                        case .indexPath(let height):
                            let size = height(IndexPath(item: row, section: 0))
                            
                            assert(size.width == nil, "Fixed width is currently unsupported.")
                            
                            guard let height = size.height else {
                                return NSTableCellView.automaticSize.height
                            }
                            
                            return height
                    }
            }
        }
        
        func numberOfRows(in tableView: NSTableView) -> Int {
            configuration.data.itemsCount
        }
        
        func tableView(
            _ tableView: NSTableView,
            objectValueFor tableColumn: NSTableColumn?,
            row: Int
        ) -> Any? {
            configuration.data.payload.first?[row]
        }
        
        func tableView(
            _ tableView: NSTableView,
            rowViewForRow row: Int
        ) -> NSTableRowView? {
            let identifier = NSUserInterfaceItemIdentifier("_PlatformTableRowView")
            
            var rowView = tableView.makeView(withIdentifier: identifier, owner: self) as? _PlatformTableView<Configuration>._NSTableRowView
            
            if rowView == nil {
                rowView = _PlatformTableView<Configuration>._NSTableRowView(parent: tableView as! _PlatformTableView<Configuration>)
                
                rowView?.identifier = identifier
            }
            
            return rowView
        }
        
        func tableView(
            _ tableView: NSTableView,
            viewFor tableColumn: NSTableColumn?,
            row: Int
        ) -> NSView? {
            guard let tableViewContainer else {
                assertionFailure()
                
                return nil
            }
            
            let identifier = NSUserInterfaceItemIdentifier("_PlatformTableCellView")
            let item = configuration.data.payload.first![row]
            let itemID = item[keyPath: configuration.data.itemID]
            let sectionID = configuration.data.payload.first!.model[keyPath: configuration.data.sectionID]
            let itemPath = _CocoaListCache<Configuration>.ItemPath(item: itemID, section: sectionID)
            
            return autoreleasepool {
                let view = (tableView.makeView(withIdentifier: identifier, owner: self) as? _PlatformTableCellView<Configuration>) ?? _PlatformTableCellView<Configuration>(
                    parent: tableViewContainer,
                    identifier: identifier
                )
                
                let payload = _PlatformTableCellView.Payload(
                    itemPath: itemPath,
                    item: item,
                    content: configuration.viewProvider.rowContent(item)
                )
                
                view.indexPath = IndexPath(item: row, section: 0)
                
                view.prepareForUse(
                    payload: payload,
                    tableView: tableView
                )

                return view
            }
        }
    }
}

extension _PlatformTableView {
    class _NSTableRowView: NSTableRowView {
        override static var requiresConstraintBasedLayout: Bool {
            true
        }

        unowned let parent: _PlatformTableView
        
        override var translatesAutoresizingMaskIntoConstraints: Bool {
            get {
                false
            } set {
                super.translatesAutoresizingMaskIntoConstraints = false
            }
        }
        
        override var intrinsicContentSize: NSSize {
            CGSize(width: AppKitOrUIKitView.noIntrinsicMetric, height: AppKitOrUIKitView.noIntrinsicMetric)
        }
        
        override var fittingSize: NSSize {
            if let cell {
                if parent.listRepresentable.configuration.preferences.cell.viewHostingOptions.detachHostingView {
                    if cell.contentHostingView.intrinsicContentSize.isRegularAndNonZero {
                        return cell.contentHostingView.intrinsicContentSize
                    }
                }
                
                if frame.size.isRegularAndNonZero, frame.size == cell.contentHostingView.intrinsicContentSize {
                    return cell.contentHostingView.intrinsicContentSize
                } else if frame.size.height == self.parent.rowHeight {
                    return cell.contentHostingView.intrinsicContentSize
                }
            }
            
            var result = super.fittingSize
            
            if let superview = self.superview {
                if superview.frame.size.isRegularAndNonZero {
                    result.width = superview.frame.size.width
                }
            }
            
            if result.height == 0 {
                if let cell = self.cell {
                    result.height = cell._cheapCache?.lastContentSize?.height ?? 0
                    
                    cell.contentHostingView._SwiftUIX_layoutIfNeeded()
                }
            }
            
            return result
        }
        
        var skipFirst: Bool = true

        override var needsUpdateConstraints: Bool {
            get {
                super.needsUpdateConstraints
            } set {
                if skipFirst {
                    skipFirst = false
                    
                    return
                }
            
                if let cell, cell.contentHostingView.intrinsicContentSize.isRegularAndNonZero {
                    if cell.contentHostingView.frame.size == self.frame.size {
                        return
                    } else {
                        if self.frame.height == self.parent.rowHeight {
                            self.frame.size = cell.contentHostingView.frame.size
                            
                            return
                        }
                    }
                }

                if subviews.isEmpty {
                    return
                }
                
                //super.needsUpdateConstraints = newValue
            }
        }
                
        var cell: _PlatformTableCellView<Configuration>? {
            if let cell = (self.subviews.first as? _PlatformTableCellView<Configuration>), cell._cheapCache?.lastContentSize != nil {
                return cell
            }
            
            return nil
        }
                
        init(parent: _PlatformTableView) {
            self.parent = parent
            
            super.init(frame: .zero)
            
            if self.parent.listRepresentable.configuration.preferences.cell.viewHostingOptions.useAutoLayout {
                self.translatesAutoresizingMaskIntoConstraints = false
            }
            
            isHorizontalContentSizeConstraintActive = false
            isVerticalContentSizeConstraintActive = false
            
            autoresizesSubviews = false
            wantsLayer = true
        }
        
        override func drawBackground(in dirtyRect: NSRect) {
            
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension _CocoaList.Coordinator {
    func reload() {
        guard let tableViewContainer, let tableView else {
            return
        }
        
        _withoutAppKitOrUIKitAnimation(self.stateFlags.contains(.isFirstRun)) {
            stateFlags.remove(.dataChanged)
            
            guard !stateFlags.contains(.didJustReload) else {
                DispatchQueue.main.async {
                    tableViewContainer.reloadData()
                }
                
                return
            }
            
            if !invalidationContext.indexes.isEmpty {
                tableView.noteHeightOfRows(withIndexesChanged: invalidationContext.indexes)
                
                invalidationContext = .init()
            }
            
            tableViewContainer.reloadData()

            stateFlags.insert(.didJustReload)
            
            DispatchQueue.main.async {
                self.stateFlags.remove(.didJustReload)
            }
        }
    }
    
    func clearInvalidationContext() {
        guard !stateFlags.contains(.isFirstRun) else {
            if !invalidationContext.indexes.isEmpty {
                tableView?.noteHeightOfRows(withIndexesChanged: invalidationContext.indexes)
            }
            
            invalidationContext = .init()

            return
        }
        
        let context = invalidationContext
        
        if !context.indexes.isEmpty {
            tableView?.noteHeightOfRows(withIndexesChanged: context.indexes)
            
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
        
        self.invalidationContext = .init()
    }
    
    func updateTableViewCells() {
        guard let tableView else {
            return
        }
        
        for cell in tableView.visibleTableViewCellViews() {
            guard let cell = cell as? _PlatformTableCellView<Configuration>, !cell.stateFlags.contains(.wasJustPutIntoUse) else {
                continue
            }
            
            guard let item = cell.payload?.item else {
                continue
            }
            
            assert(cell.payload != nil)
            
            cell.payload?.content = configuration.viewProvider.rowContent(item)
            
            _withTransactionIfNotNil(self.invalidationContext.transaction) {
                cell.refreshCellContent()
            }
        }
    }

    func _fastHeight(
        for indexPath: IndexPath
    ) -> CGFloat? {
        switch configuration.preferences.cell.sizingOptions {
            case .auto:
                return nil
            case .fixed(let width, let height):
                assert(width == nil, "Fixed width is currently unsupported.")
                
                guard let height else {
                    return nil
                }
                
                return height
            case .custom(let height):
                switch height {
                    case .indexPath(let height):
                        let size = height(indexPath)
                        
                        assert(size.width == nil, "Fixed width is currently unsupported.")
                        
                        guard let height = size.height else {
                            return nil
                        }
                        
                        return height
                }
        }
    }
}

#endif
