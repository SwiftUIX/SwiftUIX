//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension Animation {
    public static func interpolatingSpring(
        mass: Double = 1.0,
        stiffness: Double,
        friction: Double,
        tension: Double,
        initialVelocity: Double = 0
    ) -> Animation {
        let damping = friction / sqrt(2 * (1 * tension))
        
        return interpolatingSpring(
            mass: mass,
            stiffness: stiffness,
            damping: damping,
            initialVelocity: initialVelocity
        )
    }
}
