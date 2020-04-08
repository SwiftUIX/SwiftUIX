//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct PassthroughView<Content: View>: View {
    @usableFromInline
    let content: Content
     
    @inlinable
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    @inlinable
    public var body: some View {
        content
    }
}
