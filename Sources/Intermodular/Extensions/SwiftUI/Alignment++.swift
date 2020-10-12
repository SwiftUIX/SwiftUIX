//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension Alignment {
    public func isAligned(to edge: Edge) -> Bool {
        switch edge {
            case .top:
                return vertical == .top
            case .leading:
                return horizontal == .leading
            case .bottom:
                return vertical == .bottom
            case .trailing:
                return horizontal == .trailing
        }
    }
    
    public func isAligned(to edges: [Edge]) -> Bool {
        edges.map(isAligned(to:)).reduce(true, { $0 && $1 })
    }
}

extension HorizontalAlignment {
    init(from alignment: TextAlignment) {
        switch alignment {
        case .center:
            self = .center
        case .leading:
            self = .leading
        case .trailing:
            self = .trailing
        }
    }
}
