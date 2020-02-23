//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public final class UIHostingWindow<Content: View>: UIWindow {
    public var rootHostingViewController: CocoaHostingController<Content> {
        rootViewController as! CocoaHostingController<Content>
    }
    
    public var rootView: Content {
        get {
            rootHostingViewController.rootViewContent
        } set {
            rootHostingViewController.rootViewContent = newValue
        }
    }
    
    public init(windowScene: UIWindowScene, rootView: Content) {
        super.init(windowScene: windowScene)
        
        rootViewController = CocoaHostingController(rootView: rootView)
        rootViewController!.view.backgroundColor = .clear
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
