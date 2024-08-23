//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@_documentation(visibility: internal)
public enum PresentationTransitionPhase {
    case willBegin
    case didEnd
    case willDismiss
    case didDismiss
}

extension EnvironmentValues {
    var _presentationTransitionPhase: PresentationTransitionPhase? {
        get {
            self[DefaultEnvironmentKey<PresentationTransitionPhase>.self]
        } set {
            self[DefaultEnvironmentKey<PresentationTransitionPhase>.self] = newValue
        }
    }
}
