//
// Copyright (c) Vatsal Manot
//

import SwiftUI

#if canImport(UIKit)

extension Color {
    public init(_ color: UIColor) {
        var red = CGFloat()
        var green = CGFloat()
        var blue = CGFloat()
        var alpha = CGFloat()

        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        self.init(
            red: .init(red),
            green: .init(green),
            blue: .init(blue),
            opacity: .init(alpha)
        )
    }
}

#endif
