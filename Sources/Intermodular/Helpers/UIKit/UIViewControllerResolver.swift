//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import SwiftUI
import UIKit

public struct UIViewControllerResolver: UIViewControllerRepresentable {
    public class UIViewControllerType: UIViewController {
        public var onResolution: (UIViewController) -> Void = { _ in }
        
        public override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            
            if let parent = parent {
                onResolution(parent)
            }
        }
    }
    
    public let onResolution: (UIViewController) -> Void
    
    public init(onResolution: @escaping (UIViewController) -> Void) {
        self.onResolution = onResolution
    }
    
    public func makeUIViewController(context: Context) -> UIViewControllerType {
        UIViewControllerType()
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController.onResolution = onResolution
    }
}

extension View {
    public func onUIViewControllerResolution(perform action: @escaping (UIViewController) -> ()) -> some View {
        background(
            UIViewControllerResolver(onResolution: action)
        )
    }
}

#endif
