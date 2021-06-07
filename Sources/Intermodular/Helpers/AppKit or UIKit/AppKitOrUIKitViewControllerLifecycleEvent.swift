//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public enum AppKitOrUIKitViewControllerLifecycleEvent {
    case didLoad
    case willAppear
    case didAppear
    case willDisappear
    case didDisappear
    case layoutSubviews
}

struct _AppKitOrUIKitViewControllerLifecycleEventView: UIViewControllerRepresentable {
    struct Callbacks {
        var onDidLoad: ((UIViewController) -> Void)?
        var onWillAppear: ((UIViewController) -> Void)?
        var onDidAppear: ((UIViewController) -> Void)?
        var onWillDisappear: ((UIViewController) -> Void)?
        var onDidDisappear: ((UIViewController) -> Void)?
        var onWillLayoutSubviews: ((UIViewController) -> Void)?
        var onLayoutSubviews: ((UIViewController) -> Void)?
        
        mutating func setCallback(
            _ callback: ((UIViewController) -> Void)?,
            for event: AppKitOrUIKitViewControllerLifecycleEvent
        ) {
            switch event {
                case .didLoad:
                    self.onDidLoad = callback
                case .willAppear:
                    self.onWillAppear = callback
                case .didAppear:
                    self.onDidAppear = callback
                case .willDisappear:
                    self.onWillDisappear = callback
                case .didDisappear:
                    self.onDidDisappear = callback
                case .layoutSubviews:
                    self.onLayoutSubviews = callback
            }
        }
    }
    
    class UIViewControllerType: UIViewController {
        var callbacks: Callbacks?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            callbacks?.onDidLoad?(self)
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            callbacks?.onWillAppear?(self)
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            callbacks?.onDidAppear?(self)
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            
            callbacks?.onWillDisappear?(self)
        }
        
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            
            callbacks?.onDidDisappear?(self)
        }
        
        override func viewWillLayoutSubviews() {
            super.viewWillLayoutSubviews()
            
            callbacks?.onWillLayoutSubviews?(self)
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            
            callbacks?.onLayoutSubviews?(self)
        }
    }
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        UIViewControllerType()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

#endif
