//
// Copyright (c) Vatsal Manot
//

#if canImport(UIKit)

import Swift
import SwiftUI
import UIKit

extension UIRectEdge {
    public init(_ edges: [Edge]) {
        self.init()
        
        for edge in edges {
            switch edge {
                case .top:
                    formUnion(UIRectEdge.top)
                case .leading:
                    formUnion(UIRectEdge.left)
                case .bottom:
                    formUnion(UIRectEdge.bottom)
                case .trailing:
                    formUnion(UIRectEdge.right)
            }
        }
    }
}

#endif
