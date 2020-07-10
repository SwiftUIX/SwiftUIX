//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension Section where Parent == Text, Content: View, Footer == EmptyView {
    public init(header: String, @ViewBuilder content: () -> Content) {
        self.init(header: Text(header), content: content)
    }
}
