//
//  File.swift
//  SwiftUIX
//
//  Created by Yasir on 12/05/25.
//

#if os(macOS)

import SwiftUI
import AppKit

public struct BrowserNode: Identifiable, Hashable {
    public let id: UUID
    public var title: String
    public var color: NSColor
    public var children: [BrowserNode]
    
    public var isLeaf: Bool {
        children.isEmpty
    }
    
    public init(id: UUID = UUID(), title: String, color: NSColor, children: [BrowserNode] = []) {
        self.id = id
        self.title = title
        self.color = color
        self.children = children
    }
}

public class CustomBrowserCell: NSBrowserCell {
    public override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        guard let node = representedObject as? BrowserNode else {
            super.draw(withFrame: cellFrame, in: controlView)
            return
        }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 13),
            .foregroundColor: node.color
        ]
        
        let string = NSAttributedString(string: node.title, attributes: attributes)
        let textRect = NSRect(
            x: cellFrame.origin.x + 4,
            y: cellFrame.origin.y + (cellFrame.height - string.size().height) / 2,
            width: cellFrame.width - 8,
            height: string.size().height
        )
        
        string.draw(in: textRect)
    }
}

public struct BrowserWrapper: NSViewRepresentable {
    public var rootItems: [BrowserNode]
    @Binding public var selection: BrowserNode?
    
    public var reusesColumns: Bool = false
    public var hasHorizontalScroller: Bool = true
    public var autohidesScroller: Bool = true
    public var separatesColumns: Bool = true
    
    public init(rootItems: [BrowserNode], selection: Binding<BrowserNode?>) {
        self.rootItems = rootItems
        self._selection = selection
    }
    
    public func makeNSView(context: Context) -> NSBrowser {
        let browser = NSBrowser()
        browser.delegate = context.coordinator
        browser.setCellClass(CustomBrowserCell.self)
        
        browser.reusesColumns = reusesColumns
        browser.hasHorizontalScroller = hasHorizontalScroller
        browser.autohidesScroller = autohidesScroller
        browser.separatesColumns = separatesColumns
        
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
        var rootItems: [BrowserNode]
        @Binding var selection: BrowserNode?
        
        init(rootItems: [BrowserNode], selection: Binding<BrowserNode?>) {
            self.rootItems = rootItems
            self._selection = selection
        }
        
        @objc func browserClicked(_ sender: Any?) {
            guard let browser = sender as? NSBrowser,
                  let indexPath = browser.selectionIndexPath else { return }

            if let selectedNode = node(at: indexPath, from: rootItems) {
                selection = selectedNode
            }
        }

        private func node(at indexPath: IndexPath, from items: [BrowserNode]) -> BrowserNode? {
            var currentItems = items
            var selectedNode: BrowserNode?

            for index in indexPath {
                guard index < currentItems.count else { return nil }
                selectedNode = currentItems[index]
                currentItems = selectedNode?.children ?? []
            }

            return selectedNode
        }
        
        public func browser(_ browser: NSBrowser, numberOfChildrenOfItem item: Any?) -> Int {
            let children = (item as? BrowserNode)?.children ?? rootItems
            return children.count
        }
        
        public func browser(_ browser: NSBrowser, child index: Int, ofItem item: Any?) -> Any {
            let children = (item as? BrowserNode)?.children ?? rootItems
            return children[index]
        }
        
        public func browser(_ browser: NSBrowser, isLeafItem item: Any?) -> Bool {
            guard let node = item as? BrowserNode else { return true }
            return node.isLeaf
        }
        
        public func browser(_ browser: NSBrowser, objectValueForItem item: Any?) -> Any? {
            guard let node = item as? BrowserNode else { return nil }
            return node.title
        }
    }
}

public extension BrowserWrapper {
    func reusesColumns(_ value: Bool) -> BrowserWrapper {
        var copy = self
        copy.reusesColumns = value
        return copy
    }
    
    func hasHorizontalScroller(_ value: Bool) -> BrowserWrapper {
        var copy = self
        copy.hasHorizontalScroller = value
        return copy
    }
    
    func autohidesScroller(_ value: Bool) -> BrowserWrapper {
        var copy = self
        copy.autohidesScroller = value
        return copy
    }
    
    func separatesColumns(_ value: Bool) -> BrowserWrapper {
        var copy = self
        copy.separatesColumns = value
        return copy
    }
}

#endif
