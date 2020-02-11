//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

public struct CocoaPresentationHostingControllerContent: View  {
    var presentation: AnyModalPresentation
    var coordinator: CocoaPresentationCoordinator
    
    init(
        presentation: AnyModalPresentation,
        coordinator: CocoaPresentationCoordinator
    ) {
        self.presentation = presentation
        self.coordinator = coordinator
    }
    
    public var body: some View {
        presentation.content()
            .modifier(CocoaPresentationCoordinatorAttacher(coordinator: coordinator))
    }
}

#endif
