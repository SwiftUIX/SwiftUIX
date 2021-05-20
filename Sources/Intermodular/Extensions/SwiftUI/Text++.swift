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
