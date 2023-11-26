//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || targetEnvironment(macCatalyst)

private struct _OrientationLockedView<Content: View>: UIViewControllerRepresentable {
    let rootView: Content
    let supportedInterfaceOrientations: [UserInterfaceOrientation]
    
    init(rootView: Content, supportedInterfaceOrientations: [UserInterfaceOrientation]) {
        self.rootView = rootView
        self.supportedInterfaceOrientations = supportedInterfaceOrientations
    }
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        .init(rootView: rootView)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController._supportedInterfaceOrientations = supportedInterfaceOrientations
    }
    
    class UIViewControllerType: UIHostingController<Content> {
        var _supportedInterfaceOrientations: [UserInterfaceOrientation]?
        
        override var shouldAutorotate: Bool {
            false
        }
        
        override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            _supportedInterfaceOrientations.map(UIInterfaceOrientationMask.init) ?? super.supportedInterfaceOrientations
        }
        
        override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
            guard let orientation = _supportedInterfaceOrientations?.first else {
                return super.preferredInterfaceOrientationForPresentation
            }
            
            return .init(orientation)
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
        }
        
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
        }
    }
}

// MARK: - API

extension View {
    @available(OSX, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public func supportedInterfaceOrientations(
        _ supportedInterfaceOrientations: [UserInterfaceOrientation]
    ) -> some View {
        _OrientationLockedView(
            rootView: self,
            supportedInterfaceOrientations: supportedInterfaceOrientations
        )
    }
}

#endif
