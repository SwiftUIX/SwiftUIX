//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A view backed by some model type.
public protocol ModelView: View {
    associatedtype Model

    init(model: Model)
}
