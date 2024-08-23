//
// Copyright (c) Vatsal Manot
//

import SwiftUI

@_documentation(visibility: internal)
public struct _AppKitOrUIKitHostingPopoverPreferences: ExpressibleByNilLiteral, Hashable {
    public var isDetachable: Bool = false
    
    public init() {
        
    }
    
    public init(nilLiteral: ()) {
        
    }
}

@_spi(Internal)
extension _AppKitOrUIKitHostingPopoverPreferences {
    public struct _PreferenceKey: SwiftUI.PreferenceKey {
        public typealias Value = _AppKitOrUIKitHostingPopoverPreferences
        
        public static var defaultValue: Value = nil
        
        public static func reduce(
            value: inout Value,
            nextValue: () -> Value
        ) {
            value = nextValue()
        }
    }
}

extension View {
    public func _popoverWindowDetachable(_ detachable: Bool) -> some View {
        transformPreference(_AppKitOrUIKitHostingPopoverPreferences._PreferenceKey.self) {
            $0.isDetachable = detachable
        }
    }
}
