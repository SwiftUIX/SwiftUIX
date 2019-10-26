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
        case view(AnyView)
        
        case cocoaImage(AppKitOrUIKitImage)
        case cocoaView(AppKitOrUIKitView)
        
        case none
    }
    
    private(set) var itemIdentifier: String
    private(set) var content: Content
    private(set) var action: () -> () = { }
    private(set) var label: String?
    
    private(set) var isBordered: Bool = false
    
    public init(
        itemIdentifier: String,
        content: Content = .none
    ) {
        self.itemIdentifier = itemIdentifier
        self.content = content
    }
    
    public func content(_ content: Content) -> ToolbarItem {
        var result = self
        
        result.content = content
        
        return result
    }
    
    public func action(_ action: @escaping () -> ()) -> ToolbarItem {
        var result = self
        
        result.action = action
        
        return result
    }
    
    public func label(_ label: String) -> ToolbarItem {
        var result = self
        
        result.label = label
        
        return result
    }
    
    public func bordered(_ isBordered: Bool) -> ToolbarItem {
        var result = self
        
        result.isBordered = isBordered
        
        return result
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
        
        switch content {
            case let .view(view):
                result.view = NSHostingView(rootView: view)
            
            case let .cocoaImage(image):
                result.image = image
            case let .cocoaView(view):
                result.view = view
            
            case .none:
                break
        }
        
        let target = NSToolbarItemTarget(action: action)
        
        objc_setAssociatedObject(result, &ToolbarItem.targetAssociationKey, target, .OBJC_ASSOCIATION_RETAIN)
        
        result.target = target
        result.action = #selector(NSToolbarItemTarget.performAction)
        
        if let label = label {
            result.label = label
        }
        
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
    public func toolbarItem(withIdentifier identifier: String) -> ToolbarItem {
        return .init(itemIdentifier: identifier, content: .view(.init(self)))
    }
    
    public func toolbarItems(_ toolbarItems: ToolbarItem...) -> some View {
        preference(key: ToolbarViewItemsPreferenceKey.self, value: toolbarItems)
    }
}

#endif
