//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

struct _CocoaPresentationView<Content: View>: View  {
    private let coordinator: CocoaPresentationCoordinator
    private let content: () -> Content
    
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
            .environment(\.presentationManager, $presentationMode)
            .onPreferenceChange(CocoaPresentationPreferenceKey.self) { presentation in
                if let presentation = presentation {
                    self.coordinator.present(presentation: presentation)
                } else {
                    self.coordinator.dismissPresentedSheet()
                }
        }
        .onPreferenceChange(CocoaPresentationDidAttemptToDismissCallbacksPreferenceKey.self) { value in
            self.coordinator.onDidAttemptToDismiss = value
        }
        .onPreferenceChange(CocoaPresentationIsModalInPresentationPreferenceKey.self) { value in
            self.coordinator.viewController?.isModalInPresentation = value ?? false
        }
    }
}

#endif

