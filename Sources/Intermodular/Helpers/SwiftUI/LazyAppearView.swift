//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A view that appears lazily.
public struct LazyAppearView<Body: View>: View {
    private let destination: () -> Body
    
    @DelayedState private var content: Body?
    
    @inline(never)
    public init(destination: @escaping () -> Body) {
        self.destination = destination
    }
    
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
