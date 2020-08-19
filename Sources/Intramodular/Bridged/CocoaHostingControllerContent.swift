//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || os(macOS) || targetEnvironment(macCatalyst)

public struct CocoaHostingControllerContent<Content: View>: View  {
    weak var parent: CocoaController?
    
    var content: Content
    var presentationCoordinator: CocoaPresentationCoordinator?
    
    init(
        parent: CocoaController?,
        content: Content,
        presentationCoordinator: CocoaPresentationCoordinator?
    ) {
        self.content = content
        self.presentationCoordinator = presentationCoordinator
    }
    
    public var body: some View {
        content
            .environment(\.cocoaPresentationCoordinator, presentationCoordinator)
            .environment(\.presenter, presentationCoordinator)
            .environment(\.presentationManager, CocoaPresentationMode(coordinator: presentationCoordinator))
            .onPreferenceChange(ViewDescription.PreferenceKey.self, perform: {
                if let parent = self.parent as? CocoaHostingController<EnvironmentalAnyView> {
                    parent.subviewDescriptions = $0
                }
            })
            .onPreferenceChange(AnyModalPresentation.PreferenceKey.self) { presentation in
                if let presentation = presentation {
                    self.presentationCoordinator?.present(presentation)
                } else {
                    self.presentationCoordinator?.dismiss()
                }
            }
            .preference(key: AnyModalPresentation.PreferenceKey.self, value: nil)
            .onPreferenceChange(IsModalInPresentation.self) {
                self.presentationCoordinator?.setIsInPresentation($0)
            }
    }
}

#endif

