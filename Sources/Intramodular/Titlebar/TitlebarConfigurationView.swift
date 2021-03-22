//
// Copyright (c) Vatsal Manot
//

#if os(macOS) || targetEnvironment(macCatalyst)

import AppKit
import Swift
import SwiftUI

public struct TitlebarConfigurationView<Content: View>: AppKitOrUIKitViewRepresentable {
    public typealias AppKitOrUIKitViewType = AppKitOrUIKitView
    
    private let content: Content
    private let toolbar: NSToolbar
    
    public init(identifier: String = UUID().uuidString, content: () -> Content) {
        self.content = content()
        self.toolbar = NSToolbar(identifier: identifier)
    }
    
    private class HostingView<Content: View>: AppKitOrUIKitHostingView<Content> {
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
        context.coordinator.toolbar = toolbar
        
        let rootView = content.onPreferenceChange(TitlebarConfigurationViewItemsPreferenceKey.self) { items in
            context.coordinator.items = items.map({ $0.toNSToolbarItem() })
        }
        
        return HostingView(rootView: rootView).then {
            $0.toolbar = self.toolbar
        }
    }
    
    public func updateAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, context: Context) {
        toolbar.allowsUserCustomization = true
        toolbar.delegate = context.coordinator
    }
    
    public class Coordinator: NSObject, NSToolbarDelegate {
        public var toolbar: NSToolbar!
        
        public var items: [NSToolbarItem] = [] {
            didSet {
                toolbar.delegate = nil
                toolbar.delegate = self
                toolbar.setItems(items)
            }
        }
        
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
}

#elseif os(iOS)

import Swift
import SwiftUI

public typealias TitlebarConfigurationView<Content: View> = PassthroughView<Content>

#endif
