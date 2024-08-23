//
// Copyright (c) Vatsal Manot
//

#if os(macOS) || targetEnvironment(macCatalyst)

import AppKit
import Swift
import SwiftUI

@_documentation(visibility: internal)
public enum _WindowToolbarStyle {
    case automatic
    case expanded
    case unified
    case unifiedCompact
}

@_documentation(visibility: internal)
public struct TitlebarConfigurationView<Content: View>: AppKitOrUIKitViewRepresentable {
    public typealias AppKitOrUIKitViewType = AppKitOrUIKitView
    
    @State var identifier: String
    
    private let content: Content
    
    public init(
        identifier: String = UUID().uuidString,
        content: () -> Content
    ) {
        self._identifier = .init(initialValue: identifier)
        self.content = content()
    }
    
    private class HostingView<T: View>: AppKitOrUIKitHostingView<T> {
        weak var toolbar: NSToolbar?
        
        func updateToolbar() {
            #if os(macOS)
            window?.toolbar = toolbar
            #elseif targetEnvironment(macCatalyst)
            window?.windowScene?.titlebar?.toolbar = toolbar
            #endif
        }
        
        #if os(macOS)
        override open func viewDidMoveToSuperview() {
            super.viewDidMoveToWindow()
            
            updateToolbar()
        }
        
        override open func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            
            updateToolbar()
        }
        #elseif targetEnvironment(macCatalyst)
        override open func didMoveToSuperview() {
            super.didMoveToSuperview()
            
            updateToolbar()
        }
        
        override open func didMoveToWindow() {
            super.didMoveToWindow()
            
            updateToolbar()
        }
        #endif
    }
    
    public func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitViewType {
        let rootView = content.onPreferenceChange(TitlebarConfigurationViewItemsPreferenceKey.self) { items in
            context.coordinator.items = items?.map({ $0.toNSToolbarItem() })
        }
        
        return HostingView(rootView: rootView).then {
            $0.toolbar = context.coordinator.toolbar
        }
    }
    
    public func updateAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, context: Context) {
        _assignIfNotEqual(false, to: &context.coordinator.toolbar.allowsUserCustomization)
    }
    
    public class Coordinator: NSObject, NSToolbarDelegate {
        public var toolbar: NSToolbar
        
        public init(identifier: String) {
            self.toolbar = NSToolbar(identifier: identifier)
            
            super.init()
        }

        public var items: [NSToolbarItem]? = [] {
            didSet {
                if let items {
                    toolbar.delegate = self
                    
                    toolbar.setItems(items)
                } else {
                    toolbar.delegate = nil
                }
            }
        }
                
        public func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
            let items = self.items ?? []
            
            return items
                .firstIndex(where: { $0.itemIdentifier == itemIdentifier })
                .map({ items[$0] })
        }
        
        public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
            let items = self.items ?? []

            return items.map({ $0.itemIdentifier })
        }
        
        public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
            let items = self.items ?? []

            return items.map({ $0.itemIdentifier })
        }
        
        public func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
            let items = self.items ?? []

            return items.map({ $0.itemIdentifier })
        }
        
        public func toolbarWillAddItem(_ notification: Notification) {
            
        }
        
        public func toolbarDidRemoveItem(_ notification: Notification) {
            
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(identifier: identifier)
    }
}

#elseif os(iOS)

import Swift
import SwiftUI

public typealias TitlebarConfigurationView<Content: View> = PassthroughView<Content>

#endif
