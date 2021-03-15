//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public enum FrameGroup {
    public enum DimensionType: Hashable {
        case width
        case height
        
        public var orthogonal: Self {
            switch self {
                case .width:
                    return .height
                case .height:
                    return .width
            }
        }
    }
    
    public typealias ID = AnyHashable
}

public struct RelativeFrame: ExpressibleByNilLiteral, Hashable {
    struct PreferenceKey: SwiftUI.PreferenceKey {
        static let defaultValue: [RelativeFrame] = []
        
        static func reduce(value: inout [RelativeFrame], nextValue: () -> [RelativeFrame]) {
            value.append(contentsOf: nextValue())
        }
    }
    
    public let base: FrameGroup.ID?
    public let width: RelativeFrameDimension?
    public let height: RelativeFrameDimension?
    
    public init(nilLiteral: ()) {
        self.base = nil
        self.width = nil
        self.height = nil
    }
    
    public init(width: RelativeFrameDimension?, height: RelativeFrameDimension?) {
        self.base = nil
        self.width = width
        self.height = height
    }
    
    public init(width: CGFloat, height: CGFloat) {
        self.base = nil
        self.width = .width(multipliedBy: width)
        self.height = .width(multipliedBy: height)
    }
    
    public func resolve(in size: CGSize) -> CGSize {
        .init(
            width: width?.resolve(for: .width, in: size) ?? size.width,
            height: height?.resolve(for: .height, in: size) ?? size.height
        )
    }
}

public enum RelativeFrameDimension: Hashable {
    public struct FractionalValue: Hashable {
        let dimension: FrameGroup.DimensionType
        let multiplier: CGFloat
        let constant: CGFloat
        
        public init(
            dimension: FrameGroup.DimensionType,
            multiplier: CGFloat,
            constant: CGFloat = 0.0
        ) {
            self.dimension = dimension
            self.multiplier = multiplier
            self.constant = constant
        }
        
        func resolve(in size: CGSize) -> CGFloat {
            switch dimension {
                case .width:
                    return (size.width * multiplier) + constant
                case .height:
                    return (size.height * multiplier) + constant
            }
        }
    }
    
    case absolute(CGFloat)
    case fractional(FractionalValue)
    case proportional(CGFloat)
    
    func resolve(for dimensionType: FrameGroup.DimensionType, in size: CGSize) -> CGFloat {
        switch self {
            case .absolute(let value):
                return value
            case .proportional(let ratio):
                return size.value(for: dimensionType.orthogonal) * ratio
            case .fractional(let value):
                return value.resolve(in: size)
        }
    }
    
    public static func width(multipliedBy multiplier: CGFloat) -> Self {
        .fractional(.init(dimension: .width, multiplier: multiplier))
    }
    
    public static func height(multipliedBy multiplier: CGFloat) -> Self {
        .fractional(.init(dimension: .height, multiplier: multiplier))
    }
}

public struct RelativeFrameModifier: ViewModifier {
    let frame: RelativeFrame
    
    public func body(content: Content) -> some View {
        content.preference(key: RelativeFrame.PreferenceKey.self, value: [frame])
    }
}

extension View {
    public func fractionalFrame(
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        modifier(RelativeFrameModifier(frame: .init(width: width, height: height)))
    }
    
    public func relativeFrame(
        width: RelativeFrameDimension? = nil,
        height: RelativeFrameDimension? = nil
    ) -> some View {
        modifier(RelativeFrameModifier(frame: .init(width: width, height: height)))
    }
    
    public func proportionalFrame(width: CGFloat) -> some View {
        relativeFrame(width: .proportional(width))
    }
    
    public func proportionalFrame(height: CGFloat) -> some View {
        relativeFrame(height: .proportional(height))
    }
}

extension CGSize {
    public func value(for dimensionType: FrameGroup.DimensionType) -> CGFloat {
        switch dimensionType {
            case .width:
                return width
            case .height:
                return height
        }
    }
}
