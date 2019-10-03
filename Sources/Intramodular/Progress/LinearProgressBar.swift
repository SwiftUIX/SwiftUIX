//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A linear view that depicts the progress of a task over time.
public struct LinearProgressBar: View {
    private let value: CGFloat
    
    public init(_ value: CGFloat) {
        assert(value >= 0 && value <= 1)
        
        self.value = value
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                Capsule()
                    .frame(width: geometry.size.width)
                    .opacity(0.3)
                Rectangle()
                    .frame(width: geometry.size.width * self.value)
            }
        }.clipShape(Capsule())
    }
}
