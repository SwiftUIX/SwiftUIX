//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public enum UIViewControllerLifecycleEvent {
    case didLoad
    case willAppear
    case didAppear
    case willDisappear
    case didDisappear
    case layoutSubviews
}

struct _UIViewControllerLifecycleEventView<Content: View>: UIViewControllerRepresentable {
    struct Callbacks {
        var onDidLoad: (() -> Void)?
        var onWillAppear: (() -> Void)?
        var onDidAppear: (() -> Void)?
        var onWillDisappear: (() -> Void)?
        var onDidDisappear: (() -> Void)?
        var onWillLayoutSubviews: (() -> Void)?
        var onLayoutSubviews: (() -> Void)?
    }
    
    class UIViewControllerType: UIHostingController<Content> {
        var callbacks: Callbacks?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            callbacks?.onDidLoad?()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            callbacks?.onWillAppear?()
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            callbacks?.onDidAppear?()
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            
            callbacks?.onWillDisappear?()
        }
        
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            
            callbacks?.onDidDisappear?()
        }
        
        override func viewWillLayoutSubviews() {
            super.viewWillLayoutSubviews()
            
            callbacks?.onWillLayoutSubviews?()
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            
            callbacks?.onLayoutSubviews?()
        }
    }
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        UIViewControllerType()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

#endif
