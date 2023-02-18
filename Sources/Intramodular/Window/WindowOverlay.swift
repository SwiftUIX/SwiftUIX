//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI

/// A window overlay for SwiftUI.
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
    
    func makeAppKitOrUIKitViewController(context: Context) -> AppKitOrUIKitViewControllerType {
        .init(content: content, canBecomeKey: canBecomeKey, isVisible: isVisible)
    }
    
    func updateAppKitOrUIKitViewController(_ viewController: AppKitOrUIKitViewControllerType, context: Context) {
        viewController.isVisible = isVisible
        viewController.content = content
        
        viewController.updateWindow()
        
        #if os(iOS)
        if let window = viewController.contentWindow {
            let userInterfaceStyle: UIUserInterfaceStyle = context.environment.colorScheme == .light ? .light : .dark
            
            if window.overrideUserInterfaceStyle != userInterfaceStyle {
                window.overrideUserInterfaceStyle = userInterfaceStyle
                window.rootViewController?.overrideUserInterfaceStyle = userInterfaceStyle
            }
        }
        #endif
    }
    
    static func dismantleAppKitOrUIKitViewController(_ viewController: AppKitOrUIKitViewControllerType, coordinator: Coordinator) {
        DispatchQueue.asyncOnMainIfNecessary {
            if let contentWindow = viewController.contentWindow {
                #if os(iOS)
                contentWindow.isHidden = true
                #endif
                viewController.contentWindow = nil
            }
        }
    }
}

extension WindowOverlay {
    class AppKitOrUIKitViewControllerType: AppKitOrUIKitViewController {
        var content: Content {
            didSet {
                contentWindow?.rootView = content
            }
        }
        
        var canBecomeKey: Bool
        var isVisible: Binding<Bool>
        var contentWindow: AppKitOrUIKitHostingWindow<Content>?
        
        init(content: Content, canBecomeKey: Bool, isVisible: Binding<Bool>) {
            self.content = content
            self.canBecomeKey = canBecomeKey
            self.isVisible = isVisible

            super.init(nibName: nil, bundle: nil)
            
            #if os(macOS)
            view = NSView()
            #endif
        }
        
        func updateWindow() {
            if let contentWindow = contentWindow, contentWindow.isHidden == !isVisible.wrappedValue {
                return
            }
            
            if isVisible.wrappedValue {
                #if !os(macOS)
                guard let window = view?.window, let windowScene = window.windowScene else {
                    return
                }
                #endif
                
                #if os(macOS)
                let contentWindow = self.contentWindow ?? AppKitOrUIKitHostingWindow(rootView: content)
                #else
                let contentWindow = self.contentWindow ?? AppKitOrUIKitHostingWindow(
                    windowScene: windowScene,
                    rootView: content
                )
                #endif
                                
                self.contentWindow = contentWindow
                
                contentWindow.rootView = content
                contentWindow.configuration.canBecomeKey = canBecomeKey
               
                contentWindow.isVisibleBinding = isVisible
                
                #if os(iOS) || os(tvOS)
                contentWindow.windowLevel = .init(rawValue: window.windowLevel.rawValue + 1)
                #endif
                
                contentWindow.show()
            } else {
                contentWindow?.hide()
                contentWindow = nil
            }
        }
        
        @objc required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        #if !os(macOS)
        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            
            updateWindow()
        }
        #endif
    }
}

// MARK: - Helpers

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
        background(WindowOverlay(content: content(), canBecomeKey: false, isVisible: isVisible))
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
        background(WindowOverlay(content: content(), canBecomeKey: true, isVisible: isKeyAndVisible))
    }
}

// MARK: - Auxiliary

public struct WindowProxy {
    weak var window: AppKitOrUIKitHostingWindowProtocol?
    
    public func orderFrontRegardless() {
        guard let window = window else {
            return assertionFailure()
        }
        
        #if os(macOS)
        window.orderFrontRegardless()
        #endif
    }
    
    public func setMaximumLevel() {
        guard let window = window else {
            return assertionFailure()
        }
        
        #if os(iOS) || os(tvOS)
        fatalError()
        #elseif os(macOS)
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.level = .screenSaver
        #endif
    }
}

public struct WindowReader<Content: View>: View {
    @Environment(\._windowProxy) var _windowProxy: WindowProxy
    
    let content: (WindowProxy) -> Content
    
    public init(@ViewBuilder content: @escaping (WindowProxy) -> Content) {
        self.content = content
    }
    
    public var body: some View {
        content(_windowProxy)
    }
}

extension EnvironmentValues {
    struct _WindowProxyKey: EnvironmentKey {
        static let defaultValue: WindowProxy = .init(window: nil)
    }
    
    var _windowProxy: WindowProxy {
        get {
            self[_WindowProxyKey.self]
        } set {
            self[_WindowProxyKey.self] = newValue
        }
    }
}

#endif
