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
            if !(context.environment._cocoaScrollViewProxy?.base.wrappedValue === view) {
                context.environment._cocoaScrollViewProxy?.base.wrappedValue = view
            }
        }
        
        updateCocoaScrollProxy()
        
        context.coordinator.representableWillUpdate()
                
        context.coordinator.configuration = configuration

        context.coordinator.representableDidUpdate()
        
        view.representableDidUpdate(self, context: context)
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(configuration: configuration)
    }
}

extension _CocoaList {
    enum StateFlag {
        case isFirstRun
        case dataChanged
        case didJustReload
        case isNSTableViewPreparingContent
    }
    
    class InvalidationContext {
        var indexes: IndexSet = []
    }
}

extension _CocoaList {
    class Coordinator: NSObject, NSTableViewDataSource, NSTableViewDelegate {
        lazy var template = _PlatformTableCellView(parent: self.tableViewContainer!, identifier: NSUserInterfaceItemIdentifier("_PlatformTableCellView"))
        
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
            
        }
        
        func representableDidUpdate() {
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
            rowViewForRow row: Int
        ) -> NSTableRowView? {
            _PlatformTableView<Configuration>._NSTableRowView(parent: tableView as! _PlatformTableView)
        }
        
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
            viewFor tableColumn: NSTableColumn?,
            row: Int
        ) -> NSView? {
            guard let tableViewContainer, let tableView = self.tableView else {
                assertionFailure()
                
                return nil
            }
            
            let identifier = NSUserInterfaceItemIdentifier("_PlatformTableCellView")
            let item = configuration.data.payload.first![row]
            let itemID = item[keyPath: configuration.data.itemID]
            let sectionID = configuration.data.payload.first!.model[keyPath: configuration.data.sectionID]
            let itemPath = _CocoaListCache<Configuration>.ItemPath(item: itemID, section: sectionID)
            
            let view = (tableView.makeView(withIdentifier: identifier, owner: self) as? _PlatformTableCellView<Configuration>) ?? _PlatformTableCellView<Configuration>(
                parent: tableViewContainer,
                identifier: identifier
            )
            
            view.indexPath = IndexPath(item: row, section: 0)
            
            view.prepareForUse(
                payload: _PlatformTableCellView.Payload(
                    itemPath: itemPath,
                    item: item,
                    content: configuration.viewProvider.rowContent(item)
                ),
                tableView: tableView
            )
            
            return view
        }
            
        func tableView(
            _ tableView: NSTableView,
            didAdd rowView: NSTableRowView,
            forRow row: Int
        ) {
            if rowView.translatesAutoresizingMaskIntoConstraints {
                rowView.translatesAutoresizingMaskIntoConstraints = false
            }
        }
    }
}

extension _PlatformTableView {
    class _NSTableRowView: NSTableRowView {
        unowned let parent: _PlatformTableView
        
        override var fittingSize: NSSize {
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

        override var intrinsicContentSize: NSSize {
            if let cell {
                return cell.intrinsicContentSize
            } else {
                var result = CGSize(
                    width: AppKitOrUIKitView.noIntrinsicMetric,
                    height: AppKitOrUIKitView.noIntrinsicMetric
                )
                
                if let superview = self.superview {
                    if superview.frame.size.isRegularAndNonZero {
                        result.width = superview.frame.size.width
                    }
                }
                
                return result
            }
        }
        
        var cell: _PlatformTableCellView<Configuration>? {
            if let cell = (self.subviews.first as? _PlatformTableCellView<Configuration>), cell._cheapCache?.lastContentSize != nil {
                return cell
            }
            
            return nil
        }
        
        /*override var fittingSize: NSSize {
            if let cell {
                return cell.contentHostingView.fittingSize
            }
            
            return super.fittingSize
        }*/
        
        init(parent: _PlatformTableView) {
            self.parent = parent
            
            super.init(frame: .zero)
            
            self.autoresizingMask = []
            self.autoresizesSubviews = false
            self.translatesAutoresizingMaskIntoConstraints = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
                
        override func updateConstraintsForSubtreeIfNeeded() {
            super.updateConstraintsForSubtreeIfNeeded()
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
            
            cell.refreshCellContent()
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
