//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A view that appears lazily.
public struct LazyAppearView<Body: View>: View {
    private let destination: () -> Body
    
    @DelayedState private var content: Body?
    
    @_optimize(none)
    @inline(never)
    public init(destination: @escaping () -> Body) {
        self.destination = destination
    }
    
    @_optimize(none)
    @inline(never)
    public var body: some View {
        Group {
            if content == nil {
                EmptyFillView().onAppear {
                    self.content = self.destination()
                }
            } else {
                content!
            }
        }
    }
}
