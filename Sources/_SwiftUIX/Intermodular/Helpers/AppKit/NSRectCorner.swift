//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import SwiftUI

public struct NSRectCorner: OptionSet {
    public static let allCorners: Self = [.topLeft, .topRight, .bottomLeft, .bottomRight]
    
    public static let topLeft: Self = Self(rawValue: 1 << 0)
    public static let topRight: Self = Self(rawValue: 1 << 1)
    public static let bottomLeft: Self = Self(rawValue: 1 << 2)
    public static let bottomRight: Self = Self(rawValue: 1 << 3)
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

#endif
