//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol opaque_NavigatableView: opaque_View {
    var hidesBottomBarWhenPushed: Bool { get }
}

/// A view suited for display within a navigation stack.
public protocol NavigatableView: opaque_NavigatableView, View {
    var hidesBottomBarWhenPushed: Bool { get }
}

// MARK: - Implementation -

extension NavigatableView {
    public var hidesBottomBarWhenPushed: Bool {
        false
    }
}
