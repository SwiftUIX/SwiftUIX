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
    
    public func flip(axis: Axis) -> RectangleCorner {
        switch axis {
            case .vertical:
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
            case .horizontal:
                switch self {
                    case .topLeading:
                        return .topTrailing
                    case .topTrailing:
                        return .topLeading
                    case .bottomLeading:
                        return .bottomTrailing
                    case .bottomTrailing:
                        return .bottomLeading
                }
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
