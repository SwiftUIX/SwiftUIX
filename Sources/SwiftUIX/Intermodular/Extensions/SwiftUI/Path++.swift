//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if canImport(UIKit)

import UIKit

extension Path {
    /// Initialize from the immutable shape `path`.
    public init(_ path: UIBezierPath) {
        self.init(path.cgPath)
    }
}

#endif
