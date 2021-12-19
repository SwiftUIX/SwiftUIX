//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct CocoaHostingView<Content: View> {
    struct Configuration {
        var edgesIgnoringSafeArea: Bool = false
    }
    
    private var configuration: Configuration
    private let mainView: Content
    
    public init(mainView: Content) {
        self.configuration = .init()
        self.mainView = mainView
    }
    
    public init(@ViewBuilder mainView: () -> Content) {
        self.init(mainView: mainView())
    }
}

extension CocoaHostingView {
    public func edgesIgnoringSafeArea() -> Self {
        then({ $0.configuration.edgesIgnoringSafeArea = true })
    }
}

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension CocoaHostingView: AppKitOrUIKitViewControllerRepresentable {
    public typealias AppKitOrUIKitViewControllerType = CocoaHostingController<Content>
    
    public func makeAppKitOrUIKitViewController(context: Context) -> AppKitOrUIKitViewControllerType {
        let viewController = AppKitOrUIKitViewControllerType(mainView: mainView)
        
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        viewController.view.backgroundColor = .clear
        #endif
        
        if configuration.edgesIgnoringSafeArea {
            viewController._fixSafeAreaInsetsIfNecessary()
        }
        
        return viewController
    }
    
    public func updateAppKitOrUIKitViewController(_ viewController: AppKitOrUIKitViewControllerType, context: Context) {
        viewController.mainView = mainView
    }
}

#else

extension CocoaHostingView: View {
    public var body: some View {
        mainView
    }
}

#endif
