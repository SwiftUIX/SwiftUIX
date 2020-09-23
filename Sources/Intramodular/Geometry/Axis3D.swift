//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// The horizontal, vertical or zertical dimension in a 3D coordinate system.
public enum Axis3D {
    case x
    case y
    case z
    
    public var value: (x: CGFloat, y: CGFloat, z: CGFloat) {
        switch self {
            case .x:
                return (1, 0, 0)
            case .y:
                return (0, 1, 0)
            case .z:
                return (0, 0, 1)
        }
    }
    
    public init(_ axis: Axis) {
        switch axis {
            case .horizontal:
                self = .x
            case .vertical:
                self = .y
        }
    }
}

// MARK: - Helpers -

extension View {
    /// Rotates this view's rendered output in three dimensions around the given
    /// axis of rotation.
    ///
    /// Use `rotation3DEffect(_:axis:anchor:anchorZ:perspective:)` to rotate the
    /// view in three dimensions around the given axis of rotation, and
    /// optionally, position the view at a custom display order and perspective.
    ///
    /// In the example below, the text is rotated 45˚ about the `y` axis,
    /// front-most (the default `zIndex`) and default `perspective` (`1`):
    ///
    ///     Text("Rotation by passing an angle in degrees")
    ///         .rotation3DEffect(.degrees(45), axis: .y)
    ///         .border(Color.gray)
    ///
    /// ![A screenshot showing the rotation of text 45 degrees about the
    /// y-axis.](SwiftUI-View-rotation3DEffect.png)
    ///
    /// - Parameters:
    ///   - angle: The angle at which to rotate the view.
    ///   - axis: The axis of rotation.
    ///   - anchor: The location with a default of ``UnitPoint/center`` that
    ///     defines a point in 3D space about which the rotation is anchored.
    ///   - anchorZ: The location with a default of `0` that defines a point in
    ///     3D space about which the rotation is anchored.
    ///   - perspective: The relative vanishing point with a default of `1` for
    ///     this rotation.
    public func rotation3DEffect(
        _ angle: Angle,
        axis: Axis3D,
        anchor: UnitPoint = .center,
        anchorZ: CGFloat = 0,
        perspective: CGFloat = 1
    ) -> some View {
        rotation3DEffect(
            angle,
            axis: axis.value,
            anchor: anchor,
            anchorZ: anchorZ,
            perspective: perspective
        )
    }
    
    public func mirror3D(axis: Axis3D = .y) -> some View {
        rotation3DEffect(Angle(degrees: 180), axis: axis.value)
    }
}
