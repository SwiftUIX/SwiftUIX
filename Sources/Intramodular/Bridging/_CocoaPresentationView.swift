//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

struct _CocoaPresentationView<Content: View>: View  {
    let coordinator: CocoaPresentationCoordinator
    let content: () -> Content
    
    @State private var presentationMode: CocoaPresentationMode
    
    init(
        coordinator: CocoaPresentationCoordinator,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.coordinator = coordinator
        self.content = content
        
        _presentationMode = State(initialValue: CocoaPresentationMode(coordinator: coordinator))
    }
    
    var body: some View {
        content()
            .environment(\.dynamicViewPresenter, coordinator)
            .environment(\.presentationManager, $presentationMode)
            .onPreferenceChange(CocoaPresentationPreferenceKey.self) { presentation in
                if let presentation = presentation {
                    self.coordinator.present(presentation)
                } else {
                    self.coordinator.dismissPresentedView()
                }
            }
        .onPreferenceChange(CocoaPresentation.DidAttemptToDismissCallbacksPreferenceKey.self) { value in
                self.coordinator.onDidAttemptToDismiss = value
            }
            .onPreferenceChange(CocoaPresentation.IsModalInPresentationPreferenceKey.self) { value in
                self.coordinator.viewController?.isModalInPresentation = value ?? false
            }
    }
}

#endif

