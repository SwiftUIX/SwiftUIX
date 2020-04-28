//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)

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
        #if os(iOS) || targetEnvironment(macCatalyst)
        case systemSymbol(SanFranciscoSymbolName)
        case systemItem(UIBarButtonItem.SystemItem)
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
    
    #if os(macOS)
    public init<Content: View>(
        itemIdentifier: String,
        @ViewBuilder content: () -> Content
    ) {
        self.itemIdentifier = itemIdentifier
        self.content = .view(content().eraseToAnyView())
    }
    #endif
}

extension ToolbarItem {
    static var targetAssociationKey: Void = ()
    
    #if os(macOS) || targetEnvironment(macCatalyst)
    
    func toNSToolbarItem() -> NSToolbarItem {
        var result = NSToolbarItem(itemIdentifier: .init(rawValue: itemIdentifier))
        let target = NSToolbarItem._ActionTarget(action: action)
        
        switch content {
            #if os(macOS)
            case let .view(view):
                result.view = NSHostingView(rootView: view).then({
                    $0.layout()
                })
            case let .cocoaImage(image):
                result.image = image
            case let .cocoaView(view):
                result.view = view
            #endif
            
            #if targetEnvironment(macCatalyst)
            case let .systemSymbol(name):
                result.image = AppKitOrUIKitImage(systemName: name.rawValue)
            case let .systemItem(item): do {
                result = NSToolbarItem(
                    itemIdentifier: .init(rawValue: itemIdentifier),
                    barButtonItem: UIBarButtonItem(
                        barButtonSystemItem: item,
                        target: target,
                        action: #selector(NSToolbarItem._ActionTarget.performAction)
                    )
                )
            }
            #endif
            
            case .none:
                break
        }
        
        objc_setAssociatedObject(result, &ToolbarItem.targetAssociationKey, target, .OBJC_ASSOCIATION_RETAIN)
        
        result.action = #selector(NSToolbarItem._ActionTarget.performAction)
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

// MARK: - API -

extension ToolbarItem {
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

// MARK: - Auxiliary Implementation -

public struct ToolbarViewItemsPreferenceKey: PreferenceKey {
    public typealias Value = [ToolbarItem]
    
    public static var defaultValue: Value {
        []
    }
    
    public static func reduce(value: inout Value, nextValue: () -> Value) {
        
    }
}

#if os(macOS) || targetEnvironment(macCatalyst)

extension NSToolbarItem {
    class _ActionTarget: NSObject {
        private let action: () -> ()
        
        init(action: @escaping () -> ()) {
            self.action = action
        }
        
        @objc(performAction) func performAction() {
            action()
        }
    }
}

#endif

#endif
