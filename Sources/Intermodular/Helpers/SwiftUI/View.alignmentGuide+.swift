//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension View {
    /// Sets the horizontal alignment guide for an item.
    public func alignmentGuide(_ g: HorizontalAlignment) -> some View {
        alignmentGuide(g, computeValue: { $0[g] })
    }
    
    /// Sets the vertical alignment guide for an item.
    public func alignmentGuide(_ g: VerticalAlignment) -> some View {
        alignmentGuide(g, computeValue: { $0[g] })
    }
}
