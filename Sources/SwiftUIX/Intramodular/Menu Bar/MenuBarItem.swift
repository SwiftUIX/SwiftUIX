//
// Copyright (c) Vatsal Manot
//

#if canImport(AppKit)
import AppKit
#endif

import Swift
import SwiftUI

/// A model that represents an item which can be placed in the menu bar.
public struct MenuBarItem<ID, Label: View, Content: View> {
    public let id: ID
    
    internal let length: CGFloat?
    
    public let label: Label
    public let content: Content
    
    public init(
        id: ID,
        length: CGFloat?,
        label: Label,
        content: Content
    ) {
        self.id = id
        self.length = length
        self.label = label
        self.content = content
    }
}

extension MenuBarItem where Label == _MenuBarExtraLabelContent {
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
        self.init(
            id: id,
            length: length,
            label: .text(text),
            content: content()
        )
    }
}

extension MenuBarItem: Identifiable where ID: Hashable {
    
}

// MARK: - Supplementary

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
                item: MenuBarItem(
                    id: id,
                    image: image,
                    content: content
                ),
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

public enum _MenuBarExtraLabelContent: Hashable, View {
    case image(_AnyImage, size: CGSize?)
    case text(String)
    
    public var body: some View {
        switch self {
            case .image(let image, let size):
                image
                    .frame(size)
            case .text(let text):
                Text(text)
        }
    }
    
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
