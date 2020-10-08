//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || os(macOS) || targetEnvironment(macCatalyst)

public struct CocoaHostingControllerContent<Content: View>: View  {
    weak var parent: CocoaController?
    
    public var content: Content
    
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
            .modifier(_SetAppKitOrUIKitViewControllerEnvironmentValue(_appKitOrUIKitViewController: parent))
            .modifier(_UseCocoaPresentationCoordinator(coordinator: presentationCoordinator))
    }
}

#endif
