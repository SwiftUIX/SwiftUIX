//
// Copyright (c) Vatsal Manot
//


import Foundation

extension LinearGradient {
    public enum _LinearGradientDirection {
        case up
        case down
    }
    
    public init(
        gradient: Gradient,
        direction: _LinearGradientDirection = .down
    ) {
        self.init(
            gradient: gradient,
            startPoint: direction == .down ? .top : .bottom,
            endPoint: direction == .down ? .bottom : .top
        )
    }
}
