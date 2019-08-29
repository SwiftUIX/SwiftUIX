//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import ObjectiveC
import Swift
import SwiftUI

/// A toolbar item.
public struct ToolbarItem {
    public enum Content {
        case nsImage(NSImage)
        case view(AnyView)
    }

    let itemIdentifier: String
    let action: () -> ()
    let label: String
    let content: Content

    public init(
        itemIdentifier: String,
        action: @escaping () -> (),
        label: String = "",
        content: Content
    ) {
        self.itemIdentifier = itemIdentifier
        self.action = action
        self.label = label
        self.content = content
    }
}

class NSToolbarItemTarget {
    let action: () -> ()

    init(action: @escaping () -> ()) {
        self.action = action
    }

    @objc(performAction) func performAction() {
        action()
    }
}

extension ToolbarItem {
    static var targetAssociationKey: Void = ()

    func toNSToolbarItem() -> NSToolbarItem {
        let result = NSToolbarItem(itemIdentifier: .init(rawValue: itemIdentifier))

        result.label = label

        switch content {
        case let .nsImage(image):
            result.image = image
        case let .view(view):
            result.view = NSHostingView(rootView: view)
        }

        let target = NSToolbarItemTarget(action: action)

        objc_setAssociatedObject(result, &ToolbarItem.targetAssociationKey, target, .OBJC_ASSOCIATION_RETAIN)

        return result
    }
}

// MARK: - Protocol Implementations -

extension ToolbarItem: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.itemIdentifier == rhs.itemIdentifier
    }
}

// MARK: - Helpers-

public struct ToolbarViewItemsPreferenceKey: PreferenceKey {
    public typealias Value = [ToolbarItem]

    public static var defaultValue: Value {
        []
    }

    public static func reduce(value: inout Value, nextValue: () -> Value) {

    }
}

extension View {
    public func toolbarItem(withIdentifier identifier: String, action: @escaping () -> ()) -> ToolbarItem {
        return .init(itemIdentifier: identifier, action: action, content: .view(.init(self)))
    }

    public func toolbarItems(_ toolbarItems: ToolbarItem...) -> some View {
        preference(key: ToolbarViewItemsPreferenceKey.self, value: toolbarItems)
    }
}

#endif
