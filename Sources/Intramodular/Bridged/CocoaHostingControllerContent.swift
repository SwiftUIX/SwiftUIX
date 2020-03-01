//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CocoaHostingControllerContent<Content: View>: View  {
    var content: Content
    
    var presentationCoordinator: CocoaPresentationCoordinator?
    
    init(content: Content, presentationCoordinator: CocoaPresentationCoordinator?) {
        self.content = content
        self.presentationCoordinator = presentationCoordinator
    }
    
    public var body: some View {
        content
            .environment(\.cocoaPresentationCoordinator, presentationCoordinator)
            .environment(\.dynamicViewPresenter, presentationCoordinator)
            .environment(\.presentationManager, CocoaPresentationMode(coordinator: presentationCoordinator))
    }
}

#endif

