//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

@_documentation(visibility: internal)
public struct CocoaPresentationMode: PresentationManager {
    var presentationCoordinatorBox: _SwiftUIX_ObservableWeakReferenceBox<CocoaPresentationCoordinator>
    
    private var coordinator: CocoaPresentationCoordinator? {
        presentationCoordinatorBox.value
    }
    
    public var isPresented: Bool {
        coordinator != nil
    }
    
    init(coordinator: _SwiftUIX_ObservableWeakReferenceBox<CocoaPresentationCoordinator>) {
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

