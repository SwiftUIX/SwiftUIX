//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import Swift
import SwiftUI

extension _CocoaList: NSViewRepresentable {
    public typealias Coordinator = _PlatformTableView<Configuration>.Coordinator
    public typealias NSViewType = _PlatformTableView<Configuration>

    func makeNSView(
        context: Context
    ) -> NSViewType {
        NSViewType(coordinator: context.coordinator)
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
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(configuration: configuration)
    }
}

extension _PlatformTableView {
    class Coordinator: NSObject, NSTableViewDataSource, NSTableViewDelegate {
        enum DirtyFlag {
            case dataChanged
        }
        
        var dirtyFlags: Set<DirtyFlag> = []
        
        public var configuration: Configuration {
            didSet {
                if oldValue.data.id != configuration.data.id {
                    dirtyFlags.insert(.dataChanged)
                }
            }
        }
        
        weak var tableView: NSTableView?
        
        public init(configuration: Configuration) {
            self.configuration = configuration
        }
        
        func representableWillUpdate() {
            
        }
        
        func representableDidUpdate() {
            if self.dirtyFlags.contains(.dataChanged) {
                tableView?.reloadData()
                tableView?.scrollToEndOfDocument(nil)
            } else {
                _ = tableView
            }
            
            self.dirtyFlags = []
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
            configuration.data.payload.first?[row]
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
