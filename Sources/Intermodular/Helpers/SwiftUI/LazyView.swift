//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A lazily loaded view.
public struct LazyView<Body: View>: View {
    private let destination: () -> Body
    
    @_optimize(none)
    @inline(never)
    public init(destination: @escaping () -> Body) {
        self.destination = destination
    }
    
    @_optimize(none)
    @inline(never)
    public var body: some View {
        destination()
    }
}

/// A view that appears lazily.
public struct LazyAppearView<Body: View>: View {
    private let destination: () -> Body
    
    @DelayedState var content: Body?
    
    @_optimize(none)
    @inline(never)
    public init(destination: @escaping () -> Body) {
        self.destination = destination
    }
    
    @_optimize(none)
    @inline(never)
    public var body: some View {
        LazyView {
            PassthroughView {
                if content == nil {
                    ZeroSizeView().onAppear {
                        self.content = self.destination()
                    }
                } else {
                    content!.onDisappear {
                        self.content = nil
                    }
                }
            }
        }
    }
}
