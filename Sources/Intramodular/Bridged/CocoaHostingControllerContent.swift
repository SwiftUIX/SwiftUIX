//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CocoaHostingControllerContent<Content: View>: View  {
    var content: Content
    var presentation: CocoaPresentation?
    var presentationCoordinator: CocoaPresentationCoordinator
    
    @State private var presentationMode: CocoaPresentationMode
    
    init(
        content: Content,
        presentation: CocoaPresentation?,
        presentationCoordinator: CocoaPresentationCoordinator
    ) {
        self.content = content
        self.presentation = presentation
        self.presentationCoordinator = presentationCoordinator
        
        _presentationMode = State(initialValue: CocoaPresentationMode(coordinator: presentationCoordinator))
    }
    
    public var body: some View {
        content
            .environment(\.dynamicViewPresenter, presentationCoordinator.presentingCoordinator)
            .environment(\.presentationManager, $presentationMode)
            .onPreferenceChange(CocoaPresentationPreferenceKey.self) { presentation in
                if let presentation = presentation {
                    self.presentationCoordinator.present(presentation)
                } else {
                    self.presentationCoordinator.dismiss()
                }
        }
        .onPreferenceChange(
            CocoaPresentation.DidAttemptToDismissCallbacksPreferenceKey.self
        ) { value in
            self.presentationCoordinator.onDidAttemptToDismiss = value
        }
        .onPreferenceChange(
            CocoaPresentation.IsModalInPresentationPreferenceKey.self
        ) { value in
            self.presentationCoordinator.viewController?.isModalInPresentation = value ?? false
        }
        .preference(key: CocoaPresentationPreferenceKey.self, value: nil)
        .preference(key: CocoaPresentation.IsModalInPresentationPreferenceKey.self, value: nil)
    }
}

#endif
