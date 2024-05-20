//
// Copyright (c) Vatsal Manot
//

import SwiftUI

public protocol _AppKitOrUIKitApplicationDelegateItem: Identifiable {
    
}

#if os(macOS)

@propertyWrapper
public struct _CocoaApplicationDelegateAdaptor: DynamicProperty {
    private static var items: (() -> [any _AppKitOrUIKitApplicationDelegateItem])?
    
    public final class AppDelegate: NSObject, NSApplicationDelegate {
        private var items: [AnyHashable: any _AppKitOrUIKitApplicationDelegateItem] = [:]
        
        override init() {
            
        }
        
        public func applicationDidFinishLaunching(_ notification: Notification) {
            for item in (_CocoaApplicationDelegateAdaptor.items?() ?? []) {
                self.items[item._opaque_id] = item
            }
        }
    }
    
    @NSApplicationDelegateAdaptor
    public var wrappedValue: AppDelegate
    
    public init() {
        
    }
    
    public init(
        @SwiftUIX._ArrayBuilder<any _AppKitOrUIKitApplicationDelegateItem> _ items: @escaping () -> [any _AppKitOrUIKitApplicationDelegateItem]
    ) {
        self.init()
        
        Self.items = items
    }
}

#endif

extension _AppKitOrUIKitApplicationDelegateItem {
    fileprivate var _opaque_id: AnyHashable {
        id
    }
}

#if os(macOS)
extension _AnyCocoaMenuBarExtraCoordinator: _AppKitOrUIKitApplicationDelegateItem {
    
}
#endif
