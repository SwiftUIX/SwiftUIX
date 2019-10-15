//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI

fileprivate struct WindowOverlay<RootView: View, Content: View>: UIViewControllerRepresentable {
    typealias Context = UIViewControllerRepresentableContext<Self>
    typealias UIViewControllerType = _UIHostingController
    
    class _UIHostingController: UIHostingController<RootView> {
        let content: Content
        var contentWindow: UIWindow?
        var isKeyAndVisible: Binding<Bool>
        
        init(rootView: RootView, content: Content, isKeyAndVisible: Binding<Bool>) {
            self.content = content
            self.isKeyAndVisible = isKeyAndVisible
            
            super.init(rootView: rootView)
        }
        
        func setupContentWindowIfNecessary() {
            guard contentWindow == nil, let window = view?.window, let windowScene = window.windowScene else {
                return
            }
            
            let contentWindow = UIHostingWindow(
                windowScene: windowScene,
                rootView: content
            )
            
            contentWindow.isUserInteractionEnabled = true
            contentWindow.rootViewController?.view.backgroundColor = .clear
            contentWindow.windowLevel = .init(rawValue: window.windowLevel.rawValue + 1)
            
            self.contentWindow = contentWindow
            
            setContentWindowVisibility()
        }
        
        func setContentWindowVisibility() {
            guard let contentWindow = contentWindow else {
                return
            }
            
            if isKeyAndVisible.wrappedValue {
                contentWindow.isHidden = false
                contentWindow.makeKeyAndVisible()
            } else {
                contentWindow.isHidden = true
            }
        }
        
        @objc required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override fileprivate func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
                        
            setupContentWindowIfNecessary()
        }
    }
    
    private let rootView: RootView
    private let content: Content
    private let isKeyAndVisible: Binding<Bool>
    
    init(rootView: RootView, content: Content, isKeyAndVisible: Binding<Bool>) {
        self.rootView = rootView
        self.content = content
        self.isKeyAndVisible = isKeyAndVisible
    }
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        .init(rootView: rootView, content: content, isKeyAndVisible: isKeyAndVisible)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController.rootView = rootView
        
        uiViewController.setContentWindowVisibility()
    }
    
    static func dismantleUIViewController(_ uiViewController: UIViewControllerType, coordinator: Coordinator) {
        uiViewController.contentWindow?.isHidden = true
    }
}

// MARK: - Helpers -

extension View {
    public func windowOverlay<Content: View>(isKeyAndVisible: Binding<Bool>, @ViewBuilder _ content: () -> Content) -> some View {
        WindowOverlay(rootView: self, content: content(), isKeyAndVisible: isKeyAndVisible)
    }
}

#endif
