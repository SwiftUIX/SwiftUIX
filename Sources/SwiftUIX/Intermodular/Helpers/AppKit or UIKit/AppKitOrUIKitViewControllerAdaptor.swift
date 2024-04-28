//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import SwiftUI

public struct AppKitOrUIKitViewControllerAdaptor<AppKitOrUIKitViewControllerType: AppKitOrUIKitViewController>: AppKitOrUIKitViewControllerRepresentable {
#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
    public typealias UIViewControllerType = AppKitOrUIKitViewControllerType
#elseif os(macOS)
    public typealias NSViewControllerType = AppKitOrUIKitViewControllerType
#endif
    
    private let makeAppKitOrUIKitViewControllerImpl: (Context) -> AppKitOrUIKitViewControllerType
    private let updateAppKitOrUIKitViewControllerImpl: (AppKitOrUIKitViewControllerType, Context) -> ()
    
    public init(
        _ makeController: @autoclosure @escaping () -> AppKitOrUIKitViewControllerType
    ) {
        self.makeAppKitOrUIKitViewControllerImpl = { _ in makeController() }
        self.updateAppKitOrUIKitViewControllerImpl = { _, _ in }
    }
    
    public init(
        _ makeController: @escaping () -> AppKitOrUIKitViewControllerType
    ) {
        self.makeAppKitOrUIKitViewControllerImpl = { _ in makeController() }
        self.updateAppKitOrUIKitViewControllerImpl = { _, _ in }
    }
    
    public func makeAppKitOrUIKitViewController(
        context: Context
    ) -> AppKitOrUIKitViewControllerType {
        makeAppKitOrUIKitViewControllerImpl(context)
    }
    
    public func updateAppKitOrUIKitViewController(
        _ uiViewController: AppKitOrUIKitViewControllerType,
        context: Context
    ) {
        updateAppKitOrUIKitViewControllerImpl(uiViewController, context)
    }
}

#endif
