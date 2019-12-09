//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CocoaPresentationMode: PresentationModeProtocol {
    var coordinator: CocoaPresentationCoordinator?
    
    public var isPresented: Bool {
        coordinator?.viewController != nil
    }
    
    init(coordinator: CocoaPresentationCoordinator? = nil) {
        self.coordinator = coordinator
    }
    
    public func dismiss() {
        coordinator?.dismiss()
    }
}

#endif

