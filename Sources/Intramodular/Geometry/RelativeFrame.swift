//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public enum FrameDimensionType: Hashable {
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

public struct RelativeFrame: ExpressibleByNilLiteral, Hashable {
    struct PreferenceKey: SwiftUI.PreferenceKey {
        static let defaultValue: [RelativeFrame] = []
        
        static func reduce(value: inout [RelativeFrame], nextValue: () -> [RelativeFrame]) {
            value.append(contentsOf: nextValue())
        }
    }
    
    public var id: AnyHashable?
    public var group: AnyHashable?
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
    
    @inlinable
    public func dimensionsThatFit(in size: OptionalDimensions) -> OptionalDimensions {
        .init(
            width:  width?.resolve(for: .width, in: size),
            height: height?.resolve(for: .height, in: size)
        )
    }
    
    @inlinable
    public func dimensionsThatFit(in size: CGSize) -> OptionalDimensions {
        dimensionsThatFit(in: .init(size))
    }
    
    @usableFromInline
    func sizeThatFits(in size: CGSize) -> CGSize {
        .init(dimensionsThatFit(in: size), default: size)
    }
    
    public func id(_ id: AnyHashable?) -> Self {
        var result = self
        
        result.id = id
        
        return result
    }
    
    public func group(_ group: AnyHashable) -> Self {
        var result = self
        
        result.group = group
        
        return result
    }
}

public enum RelativeFrameDimension: Hashable {
    public struct FractionalValue: Hashable {
        let dimension: FrameDimensionType
        let multiplier: CGFloat
        let constant: CGFloat
        
        public init(
            dimension: FrameDimensionType,
            multiplier: CGFloat,
            constant: CGFloat
        ) {
            self.dimension = dimension
            self.multiplier = multiplier
            self.constant = constant
        }
        
        func resolve(in dimensions: OptionalDimensions) -> CGFloat? {
            switch dimension {
                case .width:
                    return dimensions.width.map({ ($0 * multiplier) + constant })
                case .height:
                    return dimensions.height.map({ ($0 * multiplier) + constant })
            }
        }
    }
    
    case absolute(CGFloat)
    case fractional(FractionalValue)
    
    @usableFromInline
    func resolve(
        for dimensionType: FrameDimensionType,
        in dimensions: OptionalDimensions
    ) -> CGFloat? {
        switch self {
            case .absolute(let value):
                return value
            case .fractional(let value):
                return value.resolve(in: dimensions)
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
            self[RelativeFrame.ResolvedValuesEnvironmentKey.self]
        } set {
            self[RelativeFrame.ResolvedValuesEnvironmentKey.self] = newValue
        }
    }
}

@usableFromInline
struct RelativeFrameModifier: _opaque_FrameModifier, ViewModifier {
    @Environment(\._relativeFrameResolvedValues) var _relativeFrameResolvedValues
    
    @usableFromInline
    let frame: RelativeFrame
    
    /// The identifier for this relative frame. Required to propagate values via preference keys.
    @usableFromInline
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
    
    @usableFromInline
    func dimensionsThatFit(in dimensions: OptionalDimensions) -> OptionalDimensions {
        frame.dimensionsThatFit(in: dimensions)
    }
}

// MARK: - Helpers -

extension CGSize {
    fileprivate func value(for dimensionType: FrameDimensionType) -> CGFloat {
        switch dimensionType {
            case .width:
                return width
            case .height:
                return height
        }
    }
}
