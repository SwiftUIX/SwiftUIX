//
// Copyright (c) Vatsal Manot
//

import SwiftUI

public struct AdaptableForm<Content: View>: View {
    public let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        VStack {
            content
        }
    }
}
