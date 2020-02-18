//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CocoaPresentationMode: PresentationManager {
    var coordinator: CocoaPresentationCoordinator?
    
    public var isPresenting: Bool {
        coordinator != nil
    }
    
    init(coordinator: CocoaPresentationCoordinator? = nil) {
        self.coordinator = coordinator
    }
    
    public func dismiss() {
        coordinator?.dismissSelf()
    }
}

#endif

