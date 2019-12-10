//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public final class CocoaHostingView<Content: View>: UIWindow {
    public let rootView: Content
    
    public init(windowScene: UIWindowScene, rootView: Content) {
        self.rootView = rootView
        
        super.init(windowScene: windowScene)
        
        rootViewController = CocoaHostingController(rootView: rootView)
    }
    
    public convenience init(
        windowScene: UIWindowScene,
        @ViewBuilder rootView: () -> Content
    ) {
        self.init(windowScene: windowScene, rootView: rootView())
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif
