//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension Edge.Set {
    public init(from alignment: HorizontalAlignment) {
        switch alignment {
            case .leading:
                self = .leading
            case .trailing:
                self = .trailing
            default:
                self = []
        }
    }
    
    public init(from alignment: VerticalAlignment) {
        switch alignment {
            case .top:
                self = .top
            case .bottom:
                self = .bottom
            default:
                self = []
        }
    }
    
    public init(from alignment: Alignment) {
        self = []
        
        formUnion(.init(from: alignment.horizontal))
        formUnion(.init(from: alignment.vertical))
    }
}

extension Edge.Set {
    public func contains(_ axis: Axis) -> Bool {
        switch axis {
            case .horizontal: do {
                return contains(.leading) || contains(.trailing)
            }
            case .vertical: do {
                return contains(.top) || contains(.bottom)
            }
        }
    }
}
