//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension GridItem.Size {
    public static func adaptive(_ size: CGFloat) -> Self {
        .adaptive(minimum: size, maximum: size)
    }
}
