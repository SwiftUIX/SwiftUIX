//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CocoaHostingControllerContent<Content: View>: View  {
    var content: Content
    
    let presentationCoordinator: CocoaPresentationCoordinator
    
    @State var navigationController: UINavigationController?
    
    init(content: Content, presentationCoordinator: CocoaPresentationCoordinator) {
        self.content = content
        self.presentationCoordinator = presentationCoordinator
    }
    
    public var body: some View {
        content
            .environment(\.navigator, navigationController)
            .modifier(CocoaPresentationCoordinatorAttacher(coordinator: presentationCoordinator))
    }
}

#endif
