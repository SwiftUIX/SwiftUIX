//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CocoaHostingControllerContent<Content: View>: View {
    public var content: Content

    private var presentation: CocoaPresentation?
    private var presentationCoordinator: CocoaPresentationCoordinator
    public var environment: EnvironmentValues?
    
    init(
        content: Content,
        presentation: CocoaPresentation?,
        presentationCoordinator: CocoaPresentationCoordinator,
        environment: EnvironmentValues?
    ) {
        self.content = content
        self.presentationCoordinator = presentationCoordinator
    }
    
    public var body: some View {
        _CocoaPresentationView(coordinator: presentationCoordinator) {
            self.content
        }
    }
}

#endif
