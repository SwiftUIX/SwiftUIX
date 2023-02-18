//
// Copyright (c) Vatsal Manot
//

#if canImport(AppKit)
import AppKit
#endif

import Swift
import SwiftUI

/// A model that represents an item which can be placed in the menu bar.
public struct MenuBarItem<ID, Content: View> {
    public let id: ID
    public let length: CGFloat?
    public let image: ImageName
    public let imageSize: CGSize
    public let content: Content
    
    public init(
        id: ID,
        length: CGFloat? = 28.0,
        image: ImageName,
        imageSize: CGSize = .init(width: 18.0, height: 18.0),
        @ViewBuilder content: () -> Content
    ) {
        self.id = id
        self.length = length
        self.image = image
        self.imageSize = imageSize
        self.content = content()
    }
}

extension MenuBarItem: Identifiable where ID: Hashable {
    
}

// MARK: - API

#if os(macOS)

extension View {
    /// Adds a menu bar item configured to present a popover when clicked.
    public func menuBarItem<ID: Hashable, Content: View>(
        id: ID,
        image: ImageName,
        isActive: Binding<Bool>? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        modifier(
            InsertMenuBarPopover(
                item: MenuBarItem(id: id, image: image, content: content),
                isActive: isActive
            )
        )
        .background(EmptyView().id(isActive?.wrappedValue))
    }
    
    /// Adds a menu bar item configured to present a popover when clicked.
    public func menuBarItem<Content: View>(
        image: ImageName,
        isActive: Binding<Bool>? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        let content = content()
        
        return withInlineState(initialValue: UUID()) { id in
            menuBarItem(id: id.wrappedValue, image: image, isActive: isActive, content: { content })
        }
    }
    
    /// Adds a menu bar item configured to present a popover when clicked.
    public func menuBarItem<ID: Hashable, Content: View>(
        id: ID,
        systemImage image: String,
        isActive: Binding<Bool>? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        modifier(
            InsertMenuBarPopover(
                item: MenuBarItem(id: id, image: .system(image), content: content),
                isActive: isActive
            )
        )
        .background(EmptyView().id(isActive?.wrappedValue))
    }
}

#endif

// MARK: - Auxiliary

#if os(macOS)
public class MenuBarItemCoordinator<ID: Equatable, Content: View> {
    let cocoaStatusBar = NSStatusBar.system
    let cocoaStatusItem: NSStatusItem
    
    public var item: MenuBarItem<ID, Content>
    public var action: () -> Void
    
    public init(
        item: MenuBarItem<ID, Content>,
        action: @escaping () -> Void
    ) {
        self.item = item
        self.action = action
        
        cocoaStatusItem = cocoaStatusBar.statusItem(withLength: item.length ?? NSStatusItem.variableLength)
        
        cocoaStatusItem.button?.action = #selector(didActivate)
        cocoaStatusItem.button?.target = self
        
        DispatchQueue.asyncOnMainIfNecessary {
            self.update()
        }
    }
    
    private func update() {
        cocoaStatusItem.update(from: item)
    }
    
    @objc private func didActivate(_ sender: AnyObject?) {
        action()
    }
    
    deinit {
        cocoaStatusBar.removeStatusItem(cocoaStatusItem)
    }
}

extension NSStatusItem {
    fileprivate func update<ID, Content>(from item: MenuBarItem<ID, Content>) {
        self.length = item.length ?? NSStatusItem.variableLength
        
        if let button = button {
            button.image = AppKitOrUIKitImage(named: item.image)
            button.image?.size = NSSize(width: item.imageSize.width, height: item.imageSize.height)
            button.image?.isTemplate = true
        }
    }
}

struct InsertMenuBarPopover<ID: Equatable, PopoverContent: View>: ViewModifier {
    let item: MenuBarItem<ID, PopoverContent>
    let isActive: Binding<Bool>?
    
    @State private var popover: NSHostingStatusBarPopover<ID, PopoverContent>? = nil
    
    @ViewBuilder
    func body(content: Content) -> some View {
        content.background {
            PerformAction {
                if let popover = self.popover {
                    popover.item = self.item
                } else {
                    self.popover = NSHostingStatusBarPopover(item: self.item)
                }
                
                popover?.isActive = isActive
            }
        }
    }
}
#endif
