//
// Copyright (c) Vatsal Manot
//

import SwiftUI

extension Image {
    public init(systemName: SFSymbolName) {
        self.init(_systemName: systemName.rawValue)
    }
    
    public init(_systemName systemName: String) {
        #if os(macOS)
        if #available(OSX 11.0, *) {
            self.init(systemName: systemName)
        } else {
            fatalError("unimplemented")
        }
        #else
        self.init(systemName: systemName)
        #endif
    }
}

#if os(iOS) || os(tvOS) || os(visionOS)
@_spi(Internal)
extension AppKitOrUIKitImage {
    public convenience init?(_SwiftUIX_systemName systemName: String) {
        self.init(systemName: systemName)
    }
}
#elseif os(macOS)
@_spi(Internal)
extension AppKitOrUIKitImage {
    public convenience init?(_SwiftUIX_systemName systemName: String) {
        if #available(macOS 11.0, *) {
            self.init(
                systemSymbolName: systemName,
                accessibilityDescription: nil
            )
        } else {
            return nil
        }
    }
}
#endif
