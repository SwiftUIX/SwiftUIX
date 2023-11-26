//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension Edge {
    public var axis: Axis {
        switch self {
            case .top:
                return .vertical
            case .leading:
                return .horizontal
            case .bottom:
                return .vertical
            case .trailing:
                return .horizontal
        }
    }
}
