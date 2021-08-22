//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CocoaPresentationMode: PresentationManager {
    var presentationCoordinatorBox: ObservableWeakReferenceBox<CocoaPresentationCoordinator>
    
    private var coordinator: CocoaPresentationCoordinator? {
        presentationCoordinatorBox.value
    }
    
    public var isPresented: Bool {
        coordinator != nil
    }
    
    init(coordinator: ObservableWeakReferenceBox<CocoaPresentationCoordinator>) {
        self.presentationCoordinatorBox = coordinator
    }
    
    init(coordinator: CocoaPresentationCoordinator?) {
        self.presentationCoordinatorBox = .init(coordinator)
    }
    
    public func dismiss() {
        guard let coordinator = coordinator else {
            return assertionFailure()
        }
        
        coordinator.dismissSelf()
    }
}

#endif

