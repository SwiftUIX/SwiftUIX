//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension View {
    public func shadow(
        color: Color = .black,
        x: CGFloat,
        y: CGFloat,
        blur: CGFloat
    ) -> some View {
        shadow(
            color: color,
            radius: blur / 2,
            x: x,
            y: y
        )
    }
}
