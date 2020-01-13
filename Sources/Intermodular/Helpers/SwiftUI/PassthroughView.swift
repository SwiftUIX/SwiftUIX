//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct PassthroughView<Content: View>: View {
    private let content: Content
     
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        content
    }
}
