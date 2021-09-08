//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension Text {
    public static func concatenate(
        @ArrayBuilder<Text> _ items: () -> [Text]
    ) -> Self {
        items().reduce(Text(""), +)
    }
}

extension Text {
    public func kerning(_ kerning: CGFloat?) -> Text {
        kerning.map(self.kerning) ?? self
    }
}

extension Text {
    /// Applies a semi-bold font weight to the text.
    public func semibold() -> Text {
        fontWeight(.semibold)
    }
}

extension Text {
    /// Applies a linear foreground gradient to the text.
    public func foregroundLinearGradient(
        _ gradient: Gradient,
        startPoint: UnitPoint = .leading,
        endPoint: UnitPoint = .trailing
    ) -> some View {
        overlay(
            LinearGradient(
                gradient: gradient,
                startPoint: startPoint,
                endPoint: endPoint
            )
        )
        .mask(self)
    }
}
