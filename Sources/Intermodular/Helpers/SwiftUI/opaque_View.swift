//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol opaque_View {
    func eraseToAnyView() -> AnyView
}

extension opaque_View where Self: View {
    public func eraseToAnyView() -> AnyView {
        .init(self)
    }
}
