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

public protocol ModelMutatingView: ModelView {
    typealias ModelBinding = Binding<Model>
    
    init(_: Binding<Model>)
}

// MARK: - Implementation -

extension ModelMutatingView {
    public init(_ model: Model) {
        self.init(.constant(model))
    }
}
