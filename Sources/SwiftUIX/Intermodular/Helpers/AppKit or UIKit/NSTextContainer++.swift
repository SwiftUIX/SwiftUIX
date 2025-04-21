//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import SwiftUI

extension NSTextContainer {
    @_spi(Internal)
    public var _hasNormalContainerWidth: Bool {
        containerSize.width.isNormal && containerSize.width != 10000000.0
    }
}

#endif
