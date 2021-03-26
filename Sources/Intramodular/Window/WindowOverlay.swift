//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI

/// A window overlay for SwiftUI.
@usableFromInline
struct WindowOverlay<Content: View>: AppKitOrUIKitViewControllerRepresentable {
    @usableFromInline
    let content: Content
    
    @usableFromInline
    let isKeyAndVisible: Binding<Bool>
    
    @usableFromInline
    init(content: Content, isKeyAndVisible: Binding<Bool>) {
        self.content = content
        self.isKeyAndVisible = isKeyAndVisible
    }
    
    @usableFromInline
    func makeAppKitOrUIKitViewController(context: Context) -> AppKitOrUIKitViewControllerType {
        .init(content: content, isKeyAndVisible: isKeyAndVisible)
    }
    
    @usableFromInline
    func updateAppKitOrUIKitViewController(_ viewController: AppKitOrUIKitViewControllerType, context: Context) {
        viewController.isKeyAndVisible = isKeyAndVisible
        viewController.content = content
        
        viewController.updateWindow()
    }
    
    @usableFromInline
    static func dismantleAppKitOrUIKitViewController(_ viewController: AppKitOrUIKitViewControllerType, coordinator: Coordinator) {
        viewController.isKeyAndVisible.wrappedValue = false
        viewController.updateWindow()
        viewController.contentWindow = nil
    }
}

extension WindowOverlay {
    @usableFromInline
    class AppKitOrUIKitViewControllerType: AppKitOrUIKitViewController {
        @usableFromInline
        var content: Content {
            didSet {
                contentWindow?.rootView = content
            }
        }
        
        @usableFromInline
        var isKeyAndVisible: Binding<Bool>
        
        @usableFromInline
        var contentWindow: AppKitOrUIKitHostingWindow<Content>?
        #if os(macOS)
        @usableFromInline
        var contentWindowController: NSWindowController?
        #endif
        
        @usableFromInline
        init(content: Content, isKeyAndVisible: Binding<Bool>) {
            self.content = content
            self.isKeyAndVisible = isKeyAndVisible
            
            super.init(nibName: nil, bundle: nil)
            
            #if os(macOS)
            view = NSView()
            #endif
        }
        
        @usableFromInline
        func updateWindow() {
            if let contentWindow = contentWindow, contentWindow.isHidden == !isKeyAndVisible.wrappedValue {
                return
            }
            
            if isKeyAndVisible.wrappedValue {
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
                
                if self.contentWindow == nil {
                    #if os(macOS)
                    NotificationCenter.default.addObserver(self, selector: #selector(Self.windowWillClose(_:)), name: NSWindow.willCloseNotification, object: nil)
                    #endif
                }
                
                self.contentWindow = contentWindow
                #if os(macOS)
                self.contentWindowController = .init(window: contentWindow)
                #endif
                
                contentWindow.rootView = content
                
                #if os(macOS)
                contentWindow.title = ""
                contentWindowController?.showWindow(self)
                #else
                contentWindow.canResizeToFitContent = true
                contentWindow.isHidden = false
                contentWindow.isUserInteractionEnabled = true
                contentWindow.windowLevel = .init(rawValue: window.windowLevel.rawValue + 1)
                
                contentWindow.makeKeyAndVisible()
                #endif
            } else {
                #if os(macOS)
                contentWindow?.close()
                #else
                contentWindow?.isHidden = true
                contentWindow?.isUserInteractionEnabled = false
                #endif
            }
        }
                
        @usableFromInline
        @objc required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        #if !os(macOS)
        @usableFromInline
        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            
            updateWindow()
        }
        #endif
        
        #if os(macOS)
        @objc
        public func windowWillClose(_ notification: Notification?) {
            if (notification?.object as? AppKitOrUIKitHostingWindow<Content>) === contentWindow {
                isKeyAndVisible.wrappedValue = false
            }
        }
        #endif
    }
}

// MARK: - Helpers -

extension View {
    /// Makes a window key and visible when a given condition is true
    /// - Parameters:
    ///   - isKeyAndVisible: A binding to whether the window is key and visible.
    ///   - content: A closure returning the content of the window.
    public func windowOverlay<Content: View>(
        isKeyAndVisible: Binding<Bool>,
        @ViewBuilder _ content: () -> Content
    ) -> some View {
        background(WindowOverlay(content: content(), isKeyAndVisible: isKeyAndVisible))
    }
}

#endif
