//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A view associated with some model type.
public protocol ModelView: View {
    associatedtype Model
    
    init(_: Model)
}

/// A view that delivers a model.
public protocol SetModelView {
    associatedtype Model
    
    init(_ binding: SetBinding<Model>)
}

/// A view that mutates a model.
public protocol MutateModelView: ModelView {
    typealias ModelBinding = Binding<Model>
    
    init(_: Binding<Model>)
}

// MARK: - Implementation -

extension MutateModelView {
    public init(_ model: Model) {
        self.init(.constant(model))
    }
}

// MARK: - Extensions -

extension SetModelView {
    public init(_ receive: @escaping (Model) -> ()) {
        self.init(.init(set: receive))
    }
}
