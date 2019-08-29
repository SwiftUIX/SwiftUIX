//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import Swift
import SwiftUI

public struct ToolbarView<Content: View>: NSViewRepresentable {
    public typealias Context = NSViewRepresentableContext<ToolbarView>
    public typealias NSViewType = NSView

    public let content: Content

    public init(_ content: () -> Content) {
        self.content = content()
    }

    public func makeNSView(context: Context) -> NSViewType {
        let rootView = content.onPreferenceChange(ToolbarViewItemsPreferenceKey.self) { items in
            context.coordinator.items = items.map({ $0.toNSToolbarItem() })
        }

        return NSHostingView(rootView: rootView)
    }

    public func updateNSView(_ nsView: NSViewType, context: Context) {
        guard let window = nsView.window else {
            return
        }

        let toolbar: NSToolbar

        if let _toolbar = window.toolbar {
            toolbar = _toolbar
        } else {
            toolbar = NSToolbar(identifier: "toolbar")

            toolbar.allowsUserCustomization = true
            toolbar.delegate = context.coordinator
        }

        window.toolbar = toolbar
    }

    public class Coordinator: NSObject, NSToolbarDelegate {
        public var items: [NSToolbarItem] = []

        public override init() {

        }

        public func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
            return items
                .firstIndex(where: { $0.itemIdentifier == itemIdentifier })
                .map({ items[$0] })
        }

        public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
            return items.map({ $0.itemIdentifier })
        }

        public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
            return items.map({ $0.itemIdentifier })
        }

        public func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
            return items.map({ $0.itemIdentifier })
        }

        public func toolbarWillAddItem(_ notification: Notification) {

        }

        public func toolbarDidRemoveItem(_ notification: Notification) {

        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    public static func dismantleNSView(_ nsView: NSViewType, coordinator: Coordinator) {

    }
}

#endif
