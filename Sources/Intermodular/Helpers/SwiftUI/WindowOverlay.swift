//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI

/// A window overlay for SwiftUI.
@usableFromInline
struct WindowOverlay<Content: View>: UIViewControllerRepresentable {
    @usableFromInline
    typealias Context = UIViewControllerRepresentableContext<Self>
    
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
    func makeUIViewController(context: Context) -> UIViewControllerType {
        .init(content: content, isKeyAndVisible: isKeyAndVisible.wrappedValue)
    }
    
    @usableFromInline
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController.isKeyAndVisible = isKeyAndVisible.wrappedValue
        uiViewController.content = content
        
        uiViewController.updateWindow()
    }
    
    @usableFromInline
    static func dismantleUIViewController(_ uiViewController: UIViewControllerType, coordinator: Coordinator) {
        uiViewController.isKeyAndVisible = false
        uiViewController.updateWindow()
        uiViewController.contentWindow = nil
    }
}

extension WindowOverlay {
    @usableFromInline
    class UIWindowType: UIHostingWindow<Content> {
        
    }
    
    @usableFromInline
    class UIViewControllerType: UIViewController {
        @usableFromInline
        var content: Content {
            didSet {
                contentWindow?.rootView = content
            }
        }
        
        @usableFromInline
        var isKeyAndVisible: Bool
        
        @usableFromInline
        var contentWindow: UIWindowType?
        
        @usableFromInline
        init(content: Content, isKeyAndVisible: Bool) {
            self.content = content
            self.isKeyAndVisible = isKeyAndVisible
            
            super.init(nibName: nil, bundle: nil)
        }
        
        @usableFromInline
        func updateWindow() {
            if let contentWindow = contentWindow, contentWindow.isHidden == !isKeyAndVisible {
                return
            }
            
            if isKeyAndVisible {
                guard let window = view?.window, let windowScene = window.windowScene else {
                    return
                }
                
                let contentWindow = self.contentWindow ?? UIWindowType(
                    windowScene: windowScene,
                    rootView: content
                ).then {
                    self.contentWindow = $0
                }
                
                contentWindow.rootView = content
                
                contentWindow.canResizeToFitContent = true
                contentWindow.isHidden = false
                contentWindow.isUserInteractionEnabled = true
                contentWindow.windowLevel = .init(rawValue: window.windowLevel.rawValue + 1)
                
                contentWindow.makeKeyAndVisible()
            } else {
                contentWindow?.isHidden = true
                contentWindow?.isUserInteractionEnabled = false
            }
        }
        
        @usableFromInline
        @objc required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @usableFromInline
        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            
            updateWindow()
        }
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
