//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public protocol opaque_NamedView {
    var name: ViewName { get }
}

public protocol NamedView: opaque_NamedView, View {
    
}

// MARK: - Implementation -

extension NamedView {
    public var name: ViewName {
        .init(Self.self)
    }
}

extension NamedView where Body: NamedView {
    public var name: ViewName {
        body.name
    }
}
