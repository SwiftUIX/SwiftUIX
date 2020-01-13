//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A lazily loaded view.
public struct LazyView<Body: View>: View {
    private let destination: () -> Body
    
    @inline(never)
    public init(destination: @escaping () -> Body) {
        self.destination = destination
    }
    
    @inline(never)
    public var body: some View {
        return destination()
    }
}
