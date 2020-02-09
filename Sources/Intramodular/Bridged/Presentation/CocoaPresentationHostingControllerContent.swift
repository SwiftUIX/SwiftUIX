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
            .environment(\.dynamicViewPresenter, coordinator.presentingCoordinator)
            .environment(\.presentationManager, CocoaPresentationMode(coordinator: coordinator))
            .onPreferenceChange(CocoaPresentationPreferenceKey.self) { presentation in
                if let presentation = presentation {
                    self.coordinator.present(presentation)
                } else {
                    self.coordinator.dismiss()
                }
            }
            .onPreferenceChange(AnyModalPresentation.DidAttemptToDismissKey.self) { value in
                self.coordinator.onDidAttemptToDismiss = value
            }
            .onPreferenceChange(AnyModalPresentation.IsActivePreferenceKey.self) { value in
                self.coordinator.viewController?.isModalInPresentation = value ?? false
            }
            .preference(key: CocoaPresentationPreferenceKey.self, value: nil)
            .preference(key: AnyModalPresentation.IsActivePreferenceKey.self, value: nil)
    }
}

#endif
