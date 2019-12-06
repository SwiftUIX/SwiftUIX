//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A circular view that depicts the progress of a task over time.
public struct CircularProgressBar: View {
    public let value: CGFloat
    
    private var lineWidth: CGFloat = 2
    
    public init(_ value: CGFloat) {
        assert(value >= 0 && value <= 1)
        
        self.value = value
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .stroke(lineWidth: self.lineWidth)
                    .opacity(0.3)
                Circle()
                    .trim(from: 0, to: self.value)
                    .stroke(lineWidth: self.lineWidth)
                    .rotationEffect(.degrees(-90))
            }
        }
    }
    
    /// Sets the line width of the view.
    public func lineWidth(_ lineWidth: CGFloat) -> CircularProgressBar {
        then {
            $0.lineWidth = lineWidth
        }
    }
}
