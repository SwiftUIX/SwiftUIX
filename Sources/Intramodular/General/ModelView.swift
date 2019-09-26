//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A view backed by some model type.
public protocol ModelView: View {
    associatedtype Model
    
    init(_: Model)
}

public protocol ModelBindingView: ModelView {
    init(_: Binding<Model>)
}

// MARK: - Implementation -

extension ModelBindingView {
    public init(_ model: Model) {
        self.init(.constant(model))
    }
}
