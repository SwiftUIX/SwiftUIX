//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension AnyTransition {
    public static var leadCrossDissolve: AnyTransition {
        .asymmetric(
            insertion: AnyTransition
                .move(edge: .trailing)
                .combined(with: .opacity),
            removal: AnyTransition
                .move(edge: .leading)
                .combined(with: .opacity)
        )
    }
    
    public static var trailCrossDissolve: AnyTransition {
        .asymmetric(
            insertion: AnyTransition
                .move(edge: .leading)
                .combined(with: .opacity),
            removal: AnyTransition
                .move(edge: .trailing)
                .combined(with: .opacity)
        )
    }
}
