//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A corner of a rectangle.
public enum RectangleCorner: CaseIterable, Hashable {
    public static var allCases: [RectangleCorner] {
        [.topLeft, .topRight, .bottomLeft, .bottomRight]
    }
    
    case topLeft
    case topLeading
    case topRight
    case topTrailing
    case bottomLeft
    case bottomLeading
    case bottomRight
    case bottomTrailing
    
    public func flip(axis: Axis) -> RectangleCorner {
        switch axis {
            case .horizontal:
                switch self {
                    case .topLeft:
                        return .topRight
                    case .topLeading:
                        return .topTrailing
                    case .topRight:
                        return .topLeft
                    case .topTrailing:
                        return .topLeading
                    case .bottomLeft:
                        return .bottomRight
                    case .bottomLeading:
                        return .bottomTrailing
                    case .bottomRight:
                        return .bottomLeft
                    case .bottomTrailing:
                        return .bottomLeading
                }
            case .vertical:
                switch self {
                    case .topLeft:
                        return .bottomLeft
                    case .topLeading:
                        return .bottomLeading
                    case .topRight:
                        return .bottomRight
                    case .topTrailing:
                        return .bottomTrailing
                    case .bottomLeft:
                        return .topLeft
                    case .bottomLeading:
                        return .topLeading
                    case .bottomRight:
                        return .topRight
                    case .bottomTrailing:
                        return .bottomTrailing
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
                case .topLeft:
                    formUnion(.topLeft)
                case .topLeading:
                    formUnion(.topLeft) // FIXME
                case .topRight:
                    formUnion(.topRight)
                case .topTrailing:
                    formUnion(.topRight) // FIXME
                case .bottomLeft:
                    formUnion(.bottomLeft)
                case .bottomLeading:
                    formUnion(.bottomLeft) // FIXME
                case .bottomRight:
                    formUnion(.bottomRight)
                case .bottomTrailing:
                    formUnion(.bottomRight) // FIXME
            }
        }
    }
}

extension Array where Element == RectangleCorner {
    public init(_ corners: UIRectCorner) {
        self.init()
        
        if corners.contains(.topLeft) {
            append(.topLeft)
        }
        
        if corners.contains(.topRight) {
            append(.topRight)
        }
        
        if corners.contains(.bottomLeft) {
            append(.bottomLeft)
        }
        
        if corners.contains(.bottomRight) {
            append(.bottomRight)
        }
    }
}

#endif
