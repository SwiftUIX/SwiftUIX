//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension Axis {
    /// The axis orthogonal to `self`.
    public var orthogonal: Axis {
        switch self {
            case .horizontal:
                return .vertical
            case .vertical:
                return .horizontal
        }
    }
}
