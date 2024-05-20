//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI

/// A window overlay for SwiftUI.
@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
struct WindowOverlay<Content: View>: AppKitOrUIKitViewControllerRepresentable {
    private let content: Content
    private let canBecomeKey: Bool
    private let isVisible: Binding<Bool>

    init(
        content: Content,
        canBecomeKey: Bool,
        isVisible: Binding<Bool>
    ) {
        self.content = content
        self.canBecomeKey = canBecomeKey
        self.isVisible = isVisible
    }
    
    func makeAppKitOrUIKitViewController(
        context: Context
    ) -> AppKitOrUIKitViewControllerType {
        AppKitOrUIKitViewControllerType(
            content: content,
            canBecomeKey: canBecomeKey,
            isVisible: isVisible.wrappedValue
        )
    }
    
    func updateAppKitOrUIKitViewController(
        _ viewController: AppKitOrUIKitViewControllerType,
        context: Context
    ) {
        viewController.windowPresentationController._sourceAppKitOrUIKitWindow = viewController.view.window
        
        viewController.windowPresentationController.preferredColorScheme = context.environment.colorScheme
        viewController.windowPresentationController.content = content
        viewController.windowPresentationController.isVisible = isVisible.wrappedValue
        viewController.windowPresentationController._externalIsVisibleBinding = isVisible
    }
    
    static func dismantleAppKitOrUIKitViewController(
        _ viewController: AppKitOrUIKitViewControllerType,
        coordinator: Coordinator
    ) {
        DispatchQueue.asyncOnMainIfNecessary {
            viewController.windowPresentationController.isVisible = false
        }
    }
}

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension WindowOverlay {
    @available(macCatalystApplicationExtension, unavailable)
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    class AppKitOrUIKitViewControllerType: AppKitOrUIKitViewController {
        var windowPresentationController: _WindowPresentationController<Content>
        
        init(content: Content, canBecomeKey: Bool, isVisible: Bool) {
            self.windowPresentationController = _WindowPresentationController(
                content: content,
                canBecomeKey: canBecomeKey,
                isVisible: isVisible
            )

            super.init(nibName: nil, bundle: nil)
            
            #if os(macOS)
            view = NSView()
            #endif
        }
                
        @objc required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        #if !os(macOS)
        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            
            windowPresentationController._update()
        }
        #endif
    }
}

// MARK: - Helpers

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension View {
    /// Makes a window visible when a given condition is true.
    ///
    /// - Parameters:
    ///   - isVisible: A binding to whether the window is visible.
    ///   - content: A closure returning the content of the window.
    public func windowOverlay<Content: View>(
        isVisible: Binding<Bool>,
        @ViewBuilder _ content: () -> Content
    ) -> some View {
        background(
            WindowOverlay(
                content: content(),
                canBecomeKey: false,
                isVisible: isVisible
            )
        )
    }

    /// Makes a window key and visible when a given condition is true.
    ///
    /// - Parameters:
    ///   - isKeyAndVisible: A binding to whether the window is key and visible.
    ///   - content: A closure returning the content of the window.
    public func windowOverlay<Content: View>(
        isKeyAndVisible: Binding<Bool>,
        @ViewBuilder _ content: () -> Content
    ) -> some View {
        background(
            WindowOverlay(
                content: content(),
                canBecomeKey: true,
                isVisible: isKeyAndVisible
            )
        )
    }
}

#endif
