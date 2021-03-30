//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import SwiftUI
import UIKit

fileprivate struct AppKitOrUIKitViewControllerResolver: UIViewControllerRepresentable {
    class UIViewControllerType: UIViewController {
        var onResolution: (UIViewController) -> Void = { _ in }
        var onAppear: (UIViewController) -> Void = { _ in }
        var onDisappear: (UIViewController) -> Void = { _ in }
        var onDeresolution: (UIViewController) -> Void = { _ in }
        
        weak var resolvedParent: UIViewController?
        
        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            
            if let parent = parent {
                onResolution(parent)
                resolvedParent = parent
            } else if let resolvedParent = resolvedParent {
                onDeresolution(resolvedParent)
                
                self.resolvedParent = nil
            }
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            if let parent = parent {
                onAppear(parent)
            }
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            if let parent = parent {
                onDisappear(parent)
            }
        }
        
        override func removeFromParent() {
            super.removeFromParent()
            
            if let resolvedParent = resolvedParent {
                onDeresolution(resolvedParent)
                
                self.resolvedParent = nil
            }
        }
    }
    
    var onResolution: (UIViewController) -> Void
    var onAppear: (UIViewController) -> Void
    var onDisappear: (UIViewController) -> Void
    var onDeresolution: (UIViewController) -> Void
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        UIViewControllerType()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController.onResolution = onResolution
        uiViewController.onAppear = onAppear
        uiViewController.onDisappear = onDisappear
        uiViewController.onDeresolution = onDeresolution
    }
}

extension View {
    public func onAppKitOrUIKitViewControllerResolution(
        perform action: @escaping (UIViewController) -> ()
    ) -> some View {
        background(
            AppKitOrUIKitViewControllerResolver(
                onResolution: action,
                onAppear: { _ in },
                onDisappear: { _ in },
                onDeresolution: { _ in }
            )
        )
    }
    
    @_disfavoredOverload
    public func onAppKitOrUIKitViewControllerResolution(
        perform resolutionAction: @escaping (UIViewController) -> (),
        onAppear: @escaping (UIViewController) -> () = { _ in },
        onDisappear: @escaping (UIViewController) -> () = { _ in },
        onDeresolution deresolutionAction: @escaping (UIViewController) -> () = { _ in }
    ) -> some View {
        background(
            AppKitOrUIKitViewControllerResolver(
                onResolution: resolutionAction,
                onAppear: onAppear,
                onDisappear: onDisappear,
                onDeresolution: deresolutionAction
            )
        )
    }
}

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension View {
    public func onUIViewControllerResolution(
        perform action: @escaping (UIViewController) -> ()
    ) -> some View {
        onAppKitOrUIKitViewControllerResolution(perform: action)
    }
    
    @_disfavoredOverload
    public func onUIViewControllerResolution(
        perform resolutionAction: @escaping (UIViewController) -> (),
        onAppear: @escaping (UIViewController) -> () = { _ in },
        onDisappear: @escaping (UIViewController) -> () = { _ in },
        onDeresolution deresolutionAction: @escaping (UIViewController) -> () = { _ in }
    ) -> some View {
        onAppKitOrUIKitViewControllerResolution(
            perform: resolutionAction,
            onAppear: onAppear,
            onDisappear: onDisappear,
            onDeresolution: deresolutionAction
        )
    }
}

#endif

#endif
