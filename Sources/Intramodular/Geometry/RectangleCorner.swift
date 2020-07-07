//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public enum RectangleCorner: Hashable {
    case topLeading
    case topTrailing
    case bottomLeading
    case bottomTrailing
    
    public func flip() -> RectangleCorner {
        switch self {
            case .topLeading:
                return .bottomLeading
            case .topTrailing:
                return .bottomTrailing
            case .bottomLeading:
                return .topLeading
            case .bottomTrailing:
                return .bottomTrailing
        }
    }
}

// MARK: - Auxiliary Implementation -

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension UIRectCorner {
    public init(_ corners: [RectangleCorner]) {
        self.init()
        
        for corner in corners {
            switch corner {
                case .topLeading:
                    formUnion(.topLeft)
                case .topTrailing:
                    formUnion(.topRight)
                case .bottomLeading:
                    formUnion(.bottomLeft)
                case .bottomTrailing:
                    formUnion(.bottomRight)
            }
        }
    }
}

#endif
