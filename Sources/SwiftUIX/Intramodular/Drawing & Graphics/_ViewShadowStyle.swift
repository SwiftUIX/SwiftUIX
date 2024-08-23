//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@_documentation(visibility: internal)
public enum _ViewShadowStyle {
    case drop(
        color: Color = .init(.sRGBLinear, white: 0, opacity: 0.33),
        radius: CGFloat,
        x: CGFloat = 0,
        y: CGFloat = 0
    )
}

extension View {
    public func shadow(_ style: _ViewShadowStyle?) -> some View {
        switch style {
            case let .drop(color, radius, x, y):
                self.shadow(color: color, radius: radius, x: x, y: y)
            case .none:
                self.shadow(color: .clear, radius: 0, x: 0, y: 0)
        }
    }
}
