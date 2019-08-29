//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(macOS)

extension Image {
    @available(*, deprecated, message: "This function is currently unavailable on macOS.")
    public init(systemName: String) {
        fatalError() // FIXME(@vmanot)
    }
}

#endif
