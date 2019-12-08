//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension Text {
    public func kerning(_ kerning: CGFloat?) -> Text {
        kerning.map(self.kerning) ?? self
    }
}
