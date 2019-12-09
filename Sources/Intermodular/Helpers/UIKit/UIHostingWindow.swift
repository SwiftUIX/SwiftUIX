//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

public final class UIHostingWindow<Content: View>: UIWindow {
    public let rootView: Content
    
    public init(windowScene: UIWindowScene, rootView: Content) {
        self.rootView = rootView
        
        super.init(windowScene: windowScene)
        
        rootViewController = UIHostingController(rootView: rootView)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif
