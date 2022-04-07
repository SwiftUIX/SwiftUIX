//
// Copyright (c) Vatsal Manot
//

#if canImport(AppKit)
import AppKit
#endif

import Swift
import SwiftUI

/// A model that represents an item which can be placed in the status bar.
public struct StatusBarItem<ID, Content: View> {
    public let id: ID
    public let length: CGFloat
    public let image: ImageName
    public let imageSize: CGSize
    public let content: Content
    
    public init(
        id: ID,
        length: CGFloat = 28.0,
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

extension StatusBarItem: Identifiable where ID: Hashable {
    
}

// MARK: - API -

#if os(macOS)

extension View {
    /// Adds a status bar item configured to present a popover when clicked.
    public func statusBarItem<ID: Hashable, Content: View>(
        id: ID,
        image: ImageName,
        isActive: Binding<Bool>? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        modifier(
            InsertStatusBarPopover(
                item: StatusBarItem(id: id, image: image, content: content),
                isActive: isActive
            )
        )
        .background(EmptyView().id(isActive?.wrappedValue))
    }
    
    /// Adds a status bar item configured to present a popover when clicked.
    public func statusBarItem<Content: View>(
        image: ImageName,
        isActive: Binding<Bool>? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        let content = content()
        
        return withInlineState(initialValue: UUID()) { id in
            statusBarItem(id: id.wrappedValue, image: image, isActive: isActive, content: { content })
        }
    }
    
    /// Adds a status bar item configured to present a popover when clicked.
    public func statusBarItem<ID: Hashable, Content: View>(
        id: ID,
        systemImage image: String,
        isActive: Binding<Bool>? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        modifier(
            InsertStatusBarPopover(
                item: StatusBarItem(id: id, image: .system(image), content: content),
                isActive: isActive
            )
        )
        .background(EmptyView().id(isActive?.wrappedValue))
    }
}

#endif

// MARK: - Auxiliary Implementation -

#if os(macOS)

extension StatusBarItem {
    @usableFromInline
    func update(_ item: NSStatusItem) {
        item.length = length
        
        if let button = item.button {
            button.image = AppKitOrUIKitImage(named: image)
            button.image?.size = NSSize(width: imageSize.width, height: imageSize.height)
            button.image?.isTemplate = true
        }
    }
}

struct InsertStatusBarPopover<ID: Equatable, PopoverContent: View>: ViewModifier {
    let item: StatusBarItem<ID, PopoverContent>
    let isActive: Binding<Bool>?
    
    @State private var popover: NSHostingStatusBarPopover<ID, PopoverContent>? = nil
    
    @ViewBuilder
    func body(content: Content) -> some View {
        content.background {
            PerformAction {
                if let popover = self.popover {
                    popover.statusBarItem = self.item
                } else {
                    self.popover = NSHostingStatusBarPopover(item: self.item)
                }
                
                popover?.isActive = isActive
            }
        }
    }
}

#endif
