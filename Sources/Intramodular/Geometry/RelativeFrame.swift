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
    
    public var id: AnyHashable?
    public var group: FrameGroup.ID?
    public var width: RelativeFrameDimension?
    public var height: RelativeFrameDimension?
    
    public init(nilLiteral: ()) {
        
    }
    
    public init(width: RelativeFrameDimension?, height: RelativeFrameDimension?) {
        self.width = width
        self.height = height
    }
    
    public init(width: CGFloat, height: CGFloat) {
        self.width = .width(multipliedBy: width)
        self.height = .width(multipliedBy: height)
    }
    
    public func resolve(in size: CGSize) -> CGSize {
        .init(
            width: width?.resolve(for: .width, in: size) ?? size.width,
            height: height?.resolve(for: .height, in: size) ?? size.height
        )
    }
    
    public func id(_ id: AnyHashable?) -> Self {
        var result = self
        
        result.id = id
        
        return result
    }
    
    public func group(_ group: FrameGroup.ID?) -> Self {
        var result = self
        
        result.group = group
        
        return result
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
            constant: CGFloat
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
    
    func resolve(for dimensionType: FrameGroup.DimensionType, in size: CGSize) -> CGFloat {
        switch self {
            case .absolute(let value):
                return value
            case .fractional(let value):
                return value.resolve(in: size)
        }
    }
    
    public static func width(multipliedBy multiplier: CGFloat) -> Self {
        .fractional(.init(dimension: .width, multiplier: multiplier, constant: 0))
    }
    
    public static func height(multipliedBy multiplier: CGFloat) -> Self {
        .fractional(.init(dimension: .height, multiplier: multiplier, constant: 0))
    }
    
    public static func + (lhs: Self, rhs: CGFloat) -> Self {
        switch lhs {
            case .absolute(let lhsValue):
                return .absolute(lhsValue + rhs)
            case .fractional(let lhsValue):
                return .fractional(
                    .init(
                        dimension: lhsValue.dimension,
                        multiplier: lhsValue.multiplier,
                        constant: lhsValue.constant + rhs
                    )
                )
        }
    }
}

// MARK: - API -

extension View {
    public func relativeFrame(
        width: RelativeFrameDimension? = nil,
        height: RelativeFrameDimension? = nil
    ) -> some View {
        modifier(RelativeFrameModifier(frame: .init(width: width, height: height)))
    }
    
    public func proportionalFrame(width: CGFloat) -> some View {
        relativeFrame(width: .height(multipliedBy: width))
    }
    
    public func proportionalFrame(height: CGFloat) -> some View {
        relativeFrame(height: .height(multipliedBy: height))
    }
}

// MARK: - Auxiliary Implementation -

extension RelativeFrame {
    typealias ResolvedValues = [AnyHashable: OptionalDimensions]
    
    struct ResolvedValuesEnvironmentKey: EnvironmentKey {
        static let defaultValue: ResolvedValues = [:]
    }
}

extension EnvironmentValues {
    var _relativeFrameResolvedValues: RelativeFrame.ResolvedValues {
        get {
            self[RelativeFrame.ResolvedValuesEnvironmentKey]
        } set {
            self[RelativeFrame.ResolvedValuesEnvironmentKey] = newValue
        }
    }
}

public struct RelativeFrameModifier: ViewModifier {
    @Environment(\._relativeFrameResolvedValues) var _relativeFrameResolvedValues
    
    let frame: RelativeFrame
    
    @State var id: AnyHashable = UUID()
    
    var resolvedDimensions: OptionalDimensions {
        _relativeFrameResolvedValues.count == 1
            ? _relativeFrameResolvedValues.values.first!
            : (_relativeFrameResolvedValues[id] ?? nil)
    }
    
    public func body(content: Content) -> some View {
        content
            .preference(key: RelativeFrame.PreferenceKey.self, value: [frame.id(id)])
            .frame(resolvedDimensions)
    }
}

// MARK: - Helpers -

extension CGSize {
    fileprivate func value(for dimensionType: FrameGroup.DimensionType) -> CGFloat {
        switch dimensionType {
            case .width:
                return width
            case .height:
                return height
        }
    }
}
