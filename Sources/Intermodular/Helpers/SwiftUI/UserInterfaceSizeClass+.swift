//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension View {
    public func padding(
        _ edges: Edge.Set,
        _ length: CGFloat,
        for sizeClass: UserInterfaceSizeClass
    ) -> some View {
        EnvironmentValueAccessView(\.horizontalSizeClass) { horizontalSizeClass in
            self
        }
    }
}
