//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public protocol _opaque_NamedView {
    var name: ViewName { get }
}

public protocol NamedView: _opaque_NamedView, View {
    
}

// MARK: - Implementation -

extension NamedView {
    public var name: ViewName {
        .init(Self.self)
    }
}
