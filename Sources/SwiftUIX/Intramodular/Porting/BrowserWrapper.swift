//
//  File.swift
//  SwiftUIX
//
//  Created by Yasir on 12/05/25.
//

#if os(macOS)

import SwiftUI
import AppKit

public protocol BrowserItem: Identifiable, Hashable {
    var id: String { get }
    var title: String { get }
    var children: [Self] { get }
    var isLeaf: Bool { get }
    
    var color: NSColor? { get }
}

public extension BrowserItem {
    var color: NSColor? { nil }
}

public struct BrowserWrapper<Data: RandomAccessCollection>: NSViewRepresentable where Data.Element: BrowserItem {
    public var rootItems: Data
    @Binding public var selection: Data.Element?

    public var reusesColumns: Bool = false
    public var hasHorizontalScroller: Bool = true
    public var autohidesScroller: Bool = true
    public var separatesColumns: Bool = true
    public var allowsMultipleSelection: Bool = false
    public var allowsEmptySelection: Bool = true
    public var minColumnWidth: CGFloat = 100
    public var maxVisibleColumns: Int = 3
    public var backgroundColor: NSColor? = nil

    public init(rootItems: Data, selection: Binding<Data.Element?>) {
        self.rootItems = rootItems
        self._selection = selection
    }

    public func makeNSView(context: Context) -> NSBrowser {
        let browser = NSBrowser()
        browser.delegate = context.coordinator

        browser.reusesColumns = reusesColumns
        browser.hasHorizontalScroller = hasHorizontalScroller
        browser.autohidesScroller = autohidesScroller
        browser.separatesColumns = separatesColumns
        browser.allowsMultipleSelection = allowsMultipleSelection
        browser.allowsEmptySelection = allowsEmptySelection
        browser.minColumnWidth = minColumnWidth
        browser.maxVisibleColumns = maxVisibleColumns
        
        if let bgColor = backgroundColor {
            browser.backgroundColor = bgColor
        }

        browser.target = context.coordinator
        browser.action = #selector(Coordinator.browserClicked(_:))
        browser.sendAction(on: [.leftMouseDown])
        
        browser.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            browser.widthAnchor.constraint(greaterThanOrEqualToConstant: 400),
            browser.heightAnchor.constraint(greaterThanOrEqualToConstant: 300)
        ])
        
        browser.reloadColumn(0)
        return browser
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(rootItems: rootItems, selection: $selection)
    }
    
    public func updateNSView(_ nsView: NSBrowser, context: Context) {
        context.coordinator.rootItems = rootItems

        let selectedIndexPath = nsView.selectionIndexPath

        let lastColumn = nsView.lastColumn
        if lastColumn >= 0 {
            for column in 0...lastColumn {
                nsView.reloadColumn(column)
            }
        } else {
            nsView.loadColumnZero()
        }

        if let indexPath = selectedIndexPath {
            for (columnIndex, index) in indexPath.enumerated() {
                nsView.reloadColumn(columnIndex)
                nsView.selectRowIndexes(IndexSet(integer: index), inColumn: columnIndex)
            }
        }
    }
    
    public class Coordinator: NSObject, NSBrowserDelegate {
        var rootItems: Data
        @Binding var selection: Data.Element?
        
        init(rootItems: Data, selection: Binding<Data.Element?>) {
            self.rootItems = rootItems
            self._selection = selection
        }
        
        @objc func browserClicked(_ sender: Any?) {
            guard let browser = sender as? NSBrowser,
                  let indexPath = browser.selectionIndexPath else { return }

            if let selectedNode = node(at: indexPath, from: Array(rootItems)) {
                selection = selectedNode
            }
        }

        private func node(at indexPath: IndexPath, from items: [Data.Element]) -> Data.Element? {
            var currentItems = items
            var selectedNode: Data.Element?

            for index in indexPath {
                guard index < currentItems.count else { return nil }
                selectedNode = currentItems[index]
                currentItems = selectedNode?.children ?? []
            }

            return selectedNode
        }
        
        public func browser(_ browser: NSBrowser, numberOfChildrenOfItem item: Any?) -> Int {
            let children = (item as? Data.Element)?.children ?? Array(rootItems)
            return children.count
        }
        
        public func browser(_ browser: NSBrowser, child index: Int, ofItem item: Any?) -> Any {
            let children = (item as? Data.Element)?.children ?? Array(rootItems)
            return children[index]
        }
        
        public func browser(_ browser: NSBrowser, isLeafItem item: Any?) -> Bool {
            guard let node = item as? Data.Element else { return true }
            return node.isLeaf
        }
        
        public func browser(_ browser: NSBrowser, objectValueForItem item: Any?) -> Any? {
            guard let node = item as? Data.Element else { return nil }
            return node.title
        }
    }
}

extension BrowserWrapper {
    public func reusesColumns(_ value: Bool) -> Self {
        var copy = self
        copy.reusesColumns = value
        return copy
    }

    public func hasHorizontalScroller(_ value: Bool) -> Self {
        var copy = self
        copy.hasHorizontalScroller = value
        return copy
    }

    public func autohidesScroller(_ value: Bool) -> Self {
        var copy = self
        copy.autohidesScroller = value
        return copy
    }

    public func separatesColumns(_ value: Bool) -> Self {
        var copy = self
        copy.separatesColumns = value
        return copy
    }

    public func allowsMultipleSelection(_ value: Bool) -> Self {
        var copy = self
        copy.allowsMultipleSelection = value
        return copy
    }

    public func allowsEmptySelection(_ value: Bool) -> Self {
        var copy = self
        copy.allowsEmptySelection = value
        return copy
    }

    public func minColumnWidth(_ value: CGFloat) -> Self {
        var copy = self
        copy.minColumnWidth = value
        return copy
    }

    public func maxVisibleColumns(_ value: Int) -> Self {
        var copy = self
        copy.maxVisibleColumns = value
        return copy
    }

    public func backgroundColor(_ color: NSColor?) -> Self {
        var copy = self
        copy.backgroundColor = color
        return copy
    }
}

#endif
