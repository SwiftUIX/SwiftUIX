//
// Copyright (c) Vatsal Manot
//

#if os(macOS) || os(iOS)

#if targetEnvironment(macCatalyst)
import AppKit
#endif

import ObjectiveC
import Swift
import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/// A toolbar item.
public struct ToolbarItem {
    public enum Content {
        #if targetEnvironment(macCatalyst)
        case systemSymbol(SanFranciscoSymbolName)
        #endif
        
        #if os(macOS)
        case view(AnyView)
        case cocoaImage(NSImage)
        case cocoaView(NSView)
        #endif
        
        case none
    }
    
    private(set) var itemIdentifier: String
    private(set) var content: Content
    private(set) var action: () -> () = { }
    private(set) var label: String?
    private(set) var title: String?
    
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
    
    public func title(_ title: String) -> ToolbarItem {
        var result = self
        
        result.title = title
        
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
    
    #if os(macOS) || targetEnvironment(macCatalyst)
    
    func toNSToolbarItem() -> NSToolbarItem {
//barButtonItem: UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
        let result = NSToolbarItem(itemIdentifier: .init(rawValue: itemIdentifier))
        
        switch content {
            #if os(macOS)
            case let .view(view):
                result.view = NSHostingView(rootView: view)
            case let .cocoaImage(image):
                result.image = image
            case let .cocoaView(view):
                result.view = view
            #endif
            
            #if targetEnvironment(macCatalyst)
            case let .systemSymbol(name):
                result.image = AppKitOrUIKitImage(systemName: name.rawValue)
            #endif

            case .none:
                break
        }
        
        let target = NSToolbarItemTarget(action: action)
        
        objc_setAssociatedObject(result, &ToolbarItem.targetAssociationKey, target, .OBJC_ASSOCIATION_RETAIN)
        
        result.action = #selector(NSToolbarItemTarget.performAction)
        result.isEnabled = true
        result.target = target

        if let label = label {
            result.label = label
        }
        
        if let title = title {
            result.title = title
        }
        
        return result
    }
    
    #endif
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
    #if os(macOS)
    public func toolbarItem(withIdentifier identifier: String) -> ToolbarItem {
        .init(itemIdentifier: identifier, content: .view(.init(self)))
    }
    #endif
    
    public func toolbarItems(_ toolbarItems: ToolbarItem...) -> some View {
        preference(key: ToolbarViewItemsPreferenceKey.self, value: toolbarItems)
    }
}

#endif

