//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI

fileprivate struct WindowOverlay<Content: View>: UIViewControllerRepresentable {
    typealias Context = UIViewControllerRepresentableContext<Self>
    
    class UIViewControllerType: UIViewController {
        var content: Content {
            didSet {
                updateWindow()
            }
        }
        
        var contentWindow: UIHostingWindow<Content>?
        var isKeyAndVisible: Binding<Bool>
        
        init(content: Content, isKeyAndVisible: Binding<Bool>) {
            self.content = content
            self.isKeyAndVisible = isKeyAndVisible
            
            super.init(nibName: nil, bundle: nil)
        }
        
        func updateWindow() {
            let isVisible = isKeyAndVisible.wrappedValue
            
            if isVisible {
                guard let window = view?.window, let windowScene = window.windowScene else {
                    return
                }
                
                if let contentWindow = contentWindow, contentWindow.isHidden == !isVisible {
                    return
                }
                
                let contentWindow = self.contentWindow ?? UIHostingWindow(
                    windowScene: windowScene,
                    rootView: content
                ).then {
                    self.contentWindow = $0
                }
                
                contentWindow.isUserInteractionEnabled = true
                contentWindow.rootView = content
                contentWindow.windowLevel = .init(rawValue: window.windowLevel.rawValue + 1)
                contentWindow.windowScene = view.window?.windowScene
                contentWindow.isHidden = false
                contentWindow.makeKeyAndVisible()
            } else {
                contentWindow?.isHidden = true
                contentWindow?.windowScene = nil
            }
        }
        
        @objc required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override fileprivate func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            
            updateWindow()
        }
    }
    
    private let content: Content
    private let isKeyAndVisible: Binding<Bool>
    
    init(content: Content, isKeyAndVisible: Binding<Bool>) {
        self.content = content
        self.isKeyAndVisible = isKeyAndVisible
    }
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        .init(content: content, isKeyAndVisible: isKeyAndVisible)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController.content = content
    }
}

// MARK: - Helpers -

extension View {
    public func windowOverlay<Content: View>(
        isKeyAndVisible: Binding<Bool>,
        @ViewBuilder _ content: () -> Content
    ) -> some View {
        background(WindowOverlay(content: content(), isKeyAndVisible: isKeyAndVisible))
    }
}

#endif
