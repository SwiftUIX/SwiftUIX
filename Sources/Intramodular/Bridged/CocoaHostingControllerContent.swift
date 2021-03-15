//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || os(macOS) || targetEnvironment(macCatalyst)

public struct CocoaHostingControllerContent<Content: View>: View  {
    weak var parent: CocoaController?
    weak var presentationCoordinator: CocoaPresentationCoordinator?
    
    public var content: Content
    
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
            .modifier(_ResolveAppKitOrUIKitViewController())
            .modifier(_UseCocoaPresentationCoordinator(coordinator: presentationCoordinator))
    }
}

#endif
