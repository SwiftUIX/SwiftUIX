//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CocoaHostingControllerContent<Content: View>: View  {
    var content: Content
    
    let presentationCoordinator: CocoaPresentationCoordinator
    
    init(content: Content, presentationCoordinator: CocoaPresentationCoordinator) {
        self.content = content
        self.presentationCoordinator = presentationCoordinator
    }
    
    public var body: some View {
        content
            .environment(\.dynamicViewPresenter, presentationCoordinator)
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
