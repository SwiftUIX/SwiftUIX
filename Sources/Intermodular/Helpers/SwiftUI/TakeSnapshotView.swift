//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

struct TakeSnapshotView<Content: View>: UIViewControllerRepresentable {
    class _UIHostingController: UIHostingController<Content> {
        let image: Binding<UIImage?>
        
        init(image: Binding<UIImage?>, rootView: Content) {
            self.image = image
            
            super.init(rootView: rootView)
        }
        
        required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override open func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            takeSnapshot()
        }
        
        func takeSnapshot() {
            UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
            
            defer {
                UIGraphicsEndImageContext()
            }
            
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            
            image.wrappedValue =  UIGraphicsGetImageFromCurrentImageContext()
        }
    }
    
    typealias Context = UIViewControllerRepresentableContext<Self>
    typealias UIViewControllerType = _UIHostingController
    
    let image: Binding<UIImage?>
    let rootView: Content
    
    init(image: Binding<UIImage?>, rootView: Content) {
        self.image = image
        self.rootView = rootView
    }
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        .init(image: image, rootView: rootView)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController.rootView = rootView

        uiViewController.takeSnapshot()
    }
}

extension View {
    public func snapshot(to image: Binding<UIImage?>) -> some View {
        TakeSnapshotView(image: image, rootView: self)
    }
}

#endif
