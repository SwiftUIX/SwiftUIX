//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || os(macOS) || targetEnvironment(macCatalyst)

public struct CocoaHostingControllerContent<Content: View>: View  {
    weak var parent: CocoaController?
    
    public var content: Content
    
    init(parent: CocoaController?, content: Content) {
        self.content = content
    }
    
    public var body: some View {
        content
            .modifier(_ResolveAppKitOrUIKitViewController(_appKitOrUIKitViewControllerBox: .init(parent)))
            .modifier(_UseCocoaPresentationCoordinator(coordinator: parent?.presentationCoordinator))
    }
}

#endif
