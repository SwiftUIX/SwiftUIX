//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import SwiftUI

extension NSRectEdge {
    public init(_ edge: Edge) {
        switch edge {
            case .top:
                self = .maxY
            case .leading:
                self = .minX
            case .bottom:
                self = .minY
            case .trailing:
                self = .maxX
        }
    }
}

#endif
