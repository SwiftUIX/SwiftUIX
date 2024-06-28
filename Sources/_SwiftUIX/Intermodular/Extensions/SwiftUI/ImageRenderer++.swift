//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(macOS)
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension ImageRenderer {
    @MainActor
    public var appKitOrUIKitImage: AppKitOrUIKitImage? {
        self.nsImage
    }
}
#elseif canImport(UIKit)
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension ImageRenderer {
    @MainActor
    public var appKitOrUIKitImage: AppKitOrUIKitImage? {
        self.uiImage
    }
}
#endif
