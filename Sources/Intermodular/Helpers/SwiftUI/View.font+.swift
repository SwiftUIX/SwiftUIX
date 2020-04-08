//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension View {
    @inlinable
    public func font(_ font: Font, weight: Font.Weight) -> some View {
        self.font(font.weight(weight))
    }
}
