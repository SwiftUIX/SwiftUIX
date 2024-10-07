//
// Copyright (c) Vatsal Manot
//

import SwiftUI

public protocol _AppKitOrUIKitApplicationDelegateItem: Identifiable {
    
}

#if os(macOS)

@propertyWrapper
@_documentation(visibility: internal)
public struct _CocoaApplicationDelegateAdaptor: DynamicProperty {
    private static var configuration: Configuration!
    private static var items: (() -> [any _AppKitOrUIKitApplicationDelegateItem])?
    
    public final class AppDelegate: NSObject, NSApplicationDelegate {
        private var items: [AnyHashable: any _AppKitOrUIKitApplicationDelegateItem] = [:]
        
        private var configuration: Configuration {
            _CocoaApplicationDelegateAdaptor.configuration
        }
        
        override init() {
            
        }
        
        private var _activationPolicy: NSApplication.ActivationPolicy?
        
        public func applicationWillFinishLaunching(_ notification: Notification) {
            if configuration.noWindowsOnLaunch {
                _activationPolicy = NSApp.activationPolicy()
                
                NSApp.setActivationPolicy(.prohibited)
            }
        }
        
        public func applicationDidFinishLaunching(
            _ notification: Notification
        ) {
            for item in (_CocoaApplicationDelegateAdaptor.items?() ?? []) {
                self.items[item._opaque_id] = item
            }
            
            if configuration.noWindowsOnLaunch {
                for window in AppKitOrUIKitWindow._SwiftUIX_allInstances {
                    guard window._SwiftUIX_isInRegularDisplay else {
                        return
                    }
                                        
                    window.resignMain()
                    
                    if window._SwiftUIX_isFirstResponder {
                        window.resignFirstResponder()
                    }

                    Task { @MainActor in
                        if window.isVisible {
                            window.close()
                             
                            Task.detached { @MainActor in
                                if !window.isReleasedWhenClosed {
                                    window.close()
                                }
                            }
                        }
                    }
                }
            }
            
            if configuration.noWindowsOnLaunch {
                NSApp.setActivationPolicy(_activationPolicy ?? .regular)
                
                self._activationPolicy = nil
            }
        }
        
        public func applicationWillHide(_ notification: Notification) {
            
        }
        
        public func applicationShouldHandleReopen(
            _ sender: NSApplication,
            hasVisibleWindows: Bool
        ) -> Bool {
            return true
        }
    }
    
    @NSApplicationDelegateAdaptor
    public var wrappedValue: AppDelegate
    
    public init() {
        
    }
    
    public struct Configuration: Hashable, Sendable {
        public let noWindowsOnLaunch: Bool
        
        public init(noWindowsOnLaunch: Bool) {
            self.noWindowsOnLaunch = noWindowsOnLaunch
        }
        
        public init() {
            self.init(noWindowsOnLaunch: false)
        }
    }
    
    public init(
        configuration: Configuration = .init(),
        @SwiftUIX._ArrayBuilder<any _AppKitOrUIKitApplicationDelegateItem> _ items: @escaping () -> [any _AppKitOrUIKitApplicationDelegateItem] = { [] }
    ) {
        self.init()
        
        Self.configuration = configuration
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

