//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension View {
    @inlinable
    @ViewBuilder
    public func redactedIfAvailable(reason: RedactionReasons, fallbackBlurRadius: CGFloat? = 16) -> some View {
        if #available(iOS 14.0, OSX 11.0, tvOS 14.0, watchOS 7.0, *) {
            self.redacted(reason: SwiftUI.RedactionReasons(reason))
        } else {
            fallbackBlurRadius.map { self.blur(radius: $0) } ?? self
        }
    }
    
    @inlinable
    @ViewBuilder
    public func unredactedIfAvailable() -> some View {
        if #available(iOS 14.0, OSX 11.0, tvOS 14.0, watchOS 7.0, *) {
            self.unredacted()
        } else {
            self
        }
    }
}
