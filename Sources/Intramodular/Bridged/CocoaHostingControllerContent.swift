//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CocoaHostingControllerContent<Content: View>: View  {
    var content: Content
    var presentation: AnyModalPresentation?
    var presentationCoordinator: CocoaPresentationCoordinator
    
    init(
        content: Content,
        presentation: AnyModalPresentation?,
        presentationCoordinator: CocoaPresentationCoordinator
    ) {
        self.content = content
        self.presentation = presentation
        self.presentationCoordinator = presentationCoordinator
    }
    
    public var body: some View {
        content
            .environment(\.dynamicViewPresenter, presentationCoordinator.presentingCoordinator)
            .environment(\.presentationManager, CocoaPresentationMode(coordinator: presentationCoordinator))
            .onPreferenceChange(CocoaPresentationPreferenceKey.self) { presentation in
                if let presentation = presentation {
                    self.presentationCoordinator.present(presentation)
                } else {
                    self.presentationCoordinator.dismiss()
                }
            }
            .onPreferenceChange(AnyModalPresentation.DidAttemptToDismissKey.self) { value in
                self.presentationCoordinator.onDidAttemptToDismiss = value
            }
            .onPreferenceChange(AnyModalPresentation.IsActivePreferenceKey.self) { value in
                self.presentationCoordinator.viewController?.isModalInPresentation = value ?? false
            }
            .preference(key: CocoaPresentationPreferenceKey.self, value: nil)
            .preference(key: AnyModalPresentation.IsActivePreferenceKey.self, value: nil)
    }
}

#endif
