//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

enum PresentationTransitionType {
    case presentationWillBegin
    case presentationDidEnd
    case dismissalWillBegin
    case dismissalDidEnd
}

extension EnvironmentValues {
    var presentationTransitionType: PresentationTransitionType? {
        get {
            self[DefaultEnvironmentKey<PresentationTransitionType>.self]
        } set {
            self[DefaultEnvironmentKey<PresentationTransitionType>.self] = newValue
        }
    }
}
