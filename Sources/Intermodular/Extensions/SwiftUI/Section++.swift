//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension Section where Parent == Text, Content: View, Footer == EmptyView {
    public init<S: StringProtocol>(header: S, @ViewBuilder content: () -> Content) {
        self.init(header: Text(header), content: content)
    }
    
    public init<S: StringProtocol>(_ header: S, @ViewBuilder content: () -> Content) {
        self.init(header: header, content: content)
    }
}
