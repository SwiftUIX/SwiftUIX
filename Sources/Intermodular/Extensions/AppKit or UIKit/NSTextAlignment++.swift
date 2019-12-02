//
// Copyright (c) Vatsal Manot
//

#if canImport(AppKit) || canImport(UIKit)

import SwiftUI

extension NSTextAlignment {
    public init(_ alignment: TextAlignment) {
        switch alignment {
            case .leading:
                self = .left
            case .center:
                self = .center
            case .trailing:
                self = .right
        }
    }
}

#endif
