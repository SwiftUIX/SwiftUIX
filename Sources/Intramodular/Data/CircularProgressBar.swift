//
// Copyright (c) Siddarth Gandhi
//

import Swift
import SwiftUI

// A circular view that depicts the progress of a task over time.
public struct CircularProgressBar: View {
    public let value: CGFloat
    
    private var lineWidth: CGFloat = 5

    public init(_ value: CGFloat) {
        assert(value >= 0 && value <= 1)
        
        self.value = value
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                Circle()
                    .stroke(lineWidth: self.lineWidth)
                    .frame(width: geometry.size.width)
                    .opacity(0.3)
                Circle()
                    .trim(from: 0, to: self.value)
                    .stroke(lineWidth: self.lineWidth)
                    .frame(width: geometry.size.width)
                    .rotationEffect(.degrees(-90))
            }
        }
    }
    
    /// Set the border width for the circular progress bar view
    public func lineWidth(_ lineWidth: CGFloat) -> CircularProgressBar {
        var copy = self
        copy.lineWidth = lineWidth
        return copy
    }
}
