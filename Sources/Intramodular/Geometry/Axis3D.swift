//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

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
}

// MARK: - Helpers -

extension View {
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

    func mirrored3D(for axis: Axis3D = .y) -> some View {
        rotation3DEffect(Angle(degrees: 180), axis: axis.value)
    }
}
