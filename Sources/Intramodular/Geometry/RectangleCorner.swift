//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A corner of a rectangle.
public enum RectangleCorner: CaseIterable, Hashable, Sendable {
    public static var allCases: Set<Self> {
        [.topLeading, .topTrailing, .bottomLeading, .bottomTrailing]
    }
    
    case topLeading
    case topTrailing
    case bottomLeading
    case bottomTrailing
    
    public func flip(axis: Axis) -> RectangleCorner {
        switch axis {
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
        }
    }
}

extension RectangleCorner {
    @available(*, deprecated, renamed: "topLeading")
    public static var topLeft: Self {
        .topLeading
    }
    
    @available(*, deprecated, renamed: "topTrailing")
    public static var topRight: Self {
        .topTrailing
    }
    
    @available(*, deprecated, renamed: "bottomLeading")
    public static var bottomLeft: Self {
        .bottomLeading
    }
    
    @available(*, deprecated, renamed: "bottomTrailing")
    public static var bottomRight: Self {
        .bottomTrailing
    }
}

// MARK: - Auxiliary

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension AppKitOrUIKitRectCorner {
    public init<S: Sequence>(_ corners: S) where S.Element == RectangleCorner {
        self.init()
        
        for corner in corners {
            switch corner {
                case .topLeading:
                    formUnion(Self.topLeft)
                case .topTrailing:
                    formUnion(Self.topRight)
                case .bottomLeading:
                    formUnion(Self.bottomLeft)
                case .bottomTrailing:
                    formUnion(Self.bottomRight)
            }
        }
    }
}

extension RangeReplaceableCollection where Element == RectangleCorner {
    public init(_ corners: AppKitOrUIKitRectCorner) {
        self.init()
        
        if corners.contains(.topLeft) {
            append(.topLeading)
        }
        
        if corners.contains(.topRight) {
            append(.topTrailing)
        }
        
        if corners.contains(.bottomLeft) {
            append(.bottomLeading)
        }
        
        if corners.contains(.bottomRight) {
            append(.bottomTrailing)
        }
    }
}

#endif
