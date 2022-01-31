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
public struct TitlebarItem {
    public enum Content {
        #if os(iOS) || targetEnvironment(macCatalyst)
        case systemSymbol(SFSymbolName)
        case systemItem(UIBarButtonItem.SystemItem)
        #endif
        
        #if os(macOS)
        case view(AnyView)
        case cocoaImage(NSImage)
        case cocoaView(NSView)
        #endif
        
        case none
    }
    
    private(set) var id: String
    private(set) var content: Content
    private(set) var label: String?
    private(set) var title: String?
    private(set) var action: () -> () = { }
    
    private(set) var isBordered: Bool = false
    
    public init(
        id: String,
        content: Content
    ) {
        self.id = id
        self.content = content
    }
    
    public init(
        id: String,
        content: () -> Content
    ) {
        self.id = id
        self.content = content()
    }
    
    #if os(macOS)
    public init<Content: View>(
        id: String,
        @ViewBuilder content: () -> Content
    ) {
        self.id = id
        self.content = .view(content().eraseToAnyView())
    }
    #endif
}

extension TitlebarItem {
    static var targetAssociationKey: Void = ()
    
    #if os(macOS) || targetEnvironment(macCatalyst)
    
    func toNSToolbarItem() -> NSToolbarItem {
        var result = NSToolbarItem(itemIdentifier: .init(rawValue: id))
        let target = NSToolbarItem._ActionTarget(action: action)
        
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
            case let .systemItem(item): do {
                result = NSToolbarItem(
                    itemIdentifier: .init(rawValue: id),
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
        
        objc_setAssociatedObject(result, &TitlebarItem.targetAssociationKey, target, .OBJC_ASSOCIATION_RETAIN)
        
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

// MARK: - Conformances -

extension TitlebarItem: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - API -

extension TitlebarItem {
    public func content(_ content: Content) -> Self {
        var result = self
        
        result.content = content
        
        return result
    }
    
    public func action(_ action: @escaping () -> ()) -> Self {
        var result = self
        
        result.action = action
        
        return result
    }
    
    public func label(_ label: String) -> Self {
        var result = self
        
        result.label = label
        
        return result
    }
    
    public func title(_ title: String) -> Self {
        var result = self
        
        result.title = title
        
        return result
    }
    
    public func bordered(_ isBordered: Bool) -> Self {
        var result = self
        
        result.isBordered = isBordered
        
        return result
    }
}

extension View {
    public func titlebar(
        @ArrayBuilder<TitlebarItem> items: () -> [TitlebarItem]
    ) -> some View {
        background {
            TitlebarConfigurationView {
                ZeroSizeView().preference(key: TitlebarConfigurationViewItemsPreferenceKey.self, value: items())
            }
        }
    }
}

// MARK: - Auxiliary Implementation -

public struct TitlebarConfigurationViewItemsPreferenceKey: PreferenceKey {
    public typealias Value = [TitlebarItem]
    
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
