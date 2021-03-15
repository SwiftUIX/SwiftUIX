//
// Copyright (c) Vatsal Manot
//

#if canImport(AppKit)
import AppKit
#endif

import Swift
import SwiftUI

/// A model that represents an item which can be placed in the status bar.
public struct StatusItem<ID, Content: View> {
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

extension StatusItem: Identifiable where ID: Hashable {
    
}

// MARK: - API -

#if os(macOS)

extension View {
    /// Adds a status bar item configured to present a popover when clicked.
    public func statusItem<ID: Hashable, Content: View>(
        id: ID,
        image: ImageName,
        @ViewBuilder content: () -> Content
    ) -> some View {
        modifier(InsertStatusBarPopover(item: StatusItem(id: id, image: image, content: content)))
    }
    
    /// Adds a status bar item configured to present a popover when clicked.
    public func statusItem<ID: Hashable, Content: View>(
        id: ID,
        systemImage image: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        modifier(InsertStatusBarPopover(item: StatusItem(id: id, image: .system(image), content: content)))
    }
}

#endif

// MARK: - Auxiliary Implementation -

#if os(macOS)

extension StatusItem {
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
    let item: StatusItem<ID, PopoverContent>
    
    @State var popover: NSHostingStatusBarPopover<ID, PopoverContent>? = nil
    
    @ViewBuilder
    func body(content: Content) -> some View {
        PerformAction {
            if let popover = self.popover {
                popover.statusItem = self.item
            } else {
                self.popover = NSHostingStatusBarPopover(item: self.item)
            }
        }
        
        content
    }
}

#endif
