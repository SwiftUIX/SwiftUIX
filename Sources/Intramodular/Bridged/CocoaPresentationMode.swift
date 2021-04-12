//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CocoaPresentationMode: PresentationManager {
    var presentationCoordinatorBox: ObservableWeakReferenceBox<CocoaPresentationCoordinator>
    
    var coordinator: CocoaPresentationCoordinator? {
        presentationCoordinatorBox.value
    }

    public var isPresented: Bool {
        coordinator != nil
    }
        
    public func dismiss() {
        coordinator?.dismissSelf()
    }
}

#endif

