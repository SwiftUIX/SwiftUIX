//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import SwiftUI
import UIKit

fileprivate struct UIViewControllerResolver: UIViewControllerRepresentable {
    class UIViewControllerType: UIViewController {
        var onResolution: (UIViewController) -> Void = { _ in }
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
        
        override func removeFromParent() {
            super.removeFromParent()
            
            if let resolvedParent = resolvedParent {
                onDeresolution(resolvedParent)
                
                self.resolvedParent = nil
            }
        }
    }
    
    var onResolution: (UIViewController) -> Void
    var onDeresolution: (UIViewController) -> Void
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        UIViewControllerType()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController.onResolution = onResolution
        uiViewController.onDeresolution = onDeresolution
    }
}

extension View {
    public func onUIViewControllerResolution(
        perform action: @escaping (UIViewController) -> ()
    ) -> some View {
        background(
            UIViewControllerResolver(
                onResolution: action,
                onDeresolution: { _ in }
            )
        )
    }
    
    public func onUIViewControllerResolution(
        perform resolutionAction: @escaping (UIViewController) -> (),
        onDeresolution deresolutionAction: @escaping (UIViewController) -> ()
    ) -> some View {
        background(
            UIViewControllerResolver(
                onResolution: resolutionAction,
                onDeresolution: deresolutionAction
            )
        )
    }
}

#endif
