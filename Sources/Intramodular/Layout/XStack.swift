//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct XStack<Content: View>: View {
    public let alignment: Alignment
    public let content: Content
    
    public init(alignment: Alignment = .center, @ViewBuilder content: () -> Content) {
        self.alignment = alignment
        self.content = content()
    }
    
    @inlinable
    public var body: some View {
        ZStack(alignment: alignment) {
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                }
            }
            
            content
        }
    }
}
