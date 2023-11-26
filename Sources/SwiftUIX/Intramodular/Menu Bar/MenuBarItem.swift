//
// Copyright (c) Vatsal Manot
//

#if canImport(AppKit)
import AppKit
#endif

import Swift
import SwiftUI

public enum _MenuBarExtraLabelContent: Hashable {
    case image(_AnyImage, size: CGSize?)
    case text(String)
    
    public func hash(into hasher: inout Hasher) {
        switch self {
            case .image(let image, let size):
                image.hash(into: &hasher)
                
                (size?.width)?.hash(into: &hasher)
                (size?.height)?.hash(into: &hasher)
            case .text(let string):
                string.hash(into: &hasher)
        }
    }
}

/// A model that represents an item which can be placed in the menu bar.
public struct MenuBarItem<ID, Content: View> {
    public let id: ID
    
    fileprivate let length: CGFloat?
    fileprivate let label: _MenuBarExtraLabelContent
    
    public let content: Content
    
    fileprivate init(
        id: ID,
        length: CGFloat?,
        label: _MenuBarExtraLabelContent,
        content: Content
    ) {
        self.id = id
        self.length = length
        self.label = label
        self.content = content
    }
    
    public init(
        id: ID,
        length: CGFloat? = nil,
        image: _AnyImage,
        imageSize: CGSize? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            id: id,
            length: length ?? 28.0,
            label: .image(image, size: imageSize ?? CGSize(width: 18.0, height: 18.0)),
            content: content()
        )
    }
    
    public init(
        id: ID,
        length: CGFloat? = nil,
        image: _AnyImage.Name,
        imageSize: CGSize? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            id: id,
            length: length,
            label: .image(.named(image), size: imageSize),
            content: content()
        )
    }
    
    public init(
        id: ID,
        length: CGFloat? = 28.0,
        text: String,
        @ViewBuilder content: () -> Content
    ) {
        self.init(id: id, length: length, label: .text(text), content: content())
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
        image: _AnyImage.Name,
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
        image: _AnyImage.Name,
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
public class _CocoaMenuBarExtraCoordinator<ID: Equatable, Content: View> {
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
        
        cocoaStatusItem = cocoaStatusBar.statusItem(
            withLength: item.length ?? NSStatusItem.variableLength
        )
        
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
    fileprivate func update<ID, Content>(
        from item: MenuBarItem<ID, Content>
    ) {
        self.length = item.length ?? NSStatusItem.variableLength
        
        if let button = button {
            switch item.label {
                case .image(let image, let imageSize):
                    button.image = image.appKitOrUIKitImage
                    button.image?.size = imageSize ?? .init(width: 18, height: 18)
                    button.image?.isTemplate = true
                case .text(let string):
                    button.title = string
            }
        }
    }
}

struct InsertMenuBarPopover<ID: Equatable, PopoverContent: View>: ViewModifier {
    let item: MenuBarItem<ID, PopoverContent>
    let isActive: Binding<Bool>?
    
    @State private var popover: _AppKitMenuBarExtraPopover<ID, PopoverContent>? = nil
    
    @ViewBuilder
    func body(content: Content) -> some View {
        content.background {
            PerformAction {
                if let popover = self.popover {
                    popover.item = self.item
                } else {
                    self.popover = _AppKitMenuBarExtraPopover(item: self.item)
                }
                
                popover?._isActiveBinding = isActive
            }
        }
    }
}
#endif
