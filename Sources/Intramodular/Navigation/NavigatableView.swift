//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A view suited for display within a navigation stack.
public protocol NavigatableView: View {
    var hidesBottomBarWhenPushed: Bool { get }
}

extension NavigatableView {
    public var hidesBottomBarWhenPushed: Bool {
        return true
    }
}
