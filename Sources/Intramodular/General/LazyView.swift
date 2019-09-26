//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A lazily loaded view.
public struct LazyView<Body: View>: View {
    public let makeBody: () -> Body
    
    @inline(never)
    public init(_ makeBody: @autoclosure @escaping () -> Body) {
        self.makeBody = makeBody
    }
    
    @inline(never)
    public var body: some View {
        return makeBody()
    }
}
