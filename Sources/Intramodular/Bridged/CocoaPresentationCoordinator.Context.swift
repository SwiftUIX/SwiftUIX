//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

extension CocoaPresentationCoordinator {
    struct PresentationContext {
        let presentingCoordinator: CocoaPresentationCoordinator
        let presentedCoordinator: CocoaPresentationCoordinator
    }
}

extension CocoaPresentationCoordinator.PresentationContext {
    struct EnvironmentKey: SwiftUI.EnvironmentKey {
        static let defaultValue: CocoaPresentationCoordinator.PresentationContext? = nil
    }
}

extension EnvironmentValues {
    var cocoaPresentationContext: CocoaPresentationCoordinator.PresentationContext? {
        get {
            self[CocoaPresentationCoordinator.PresentationContext.EnvironmentKey]
        } set {
            self[CocoaPresentationCoordinator.PresentationContext.EnvironmentKey] = newValue
        }
    }
}
