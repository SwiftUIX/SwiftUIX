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
            
            DispatchQueue.main.async {
                self.takeSnapshot()
            }
        }
        
        func takeSnapshot() {
            guard view.superview != nil else {
                return
            }
            
            guard (view.layer.animationKeys() ?? []).count == 0 else {
                return
            }
            
            guard UIView.inheritedAnimationDuration == 0 else {
                return
            }
            
            guard view.frame.size.width >= 1 && view.frame.size.height >= 1 else {
                return
            }
            
            UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
            
            defer {
                UIGraphicsEndImageContext()
            }
            
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            
            if image.wrappedValue?.pngData() == newImage?.pngData() {
                
            } else {
                image.wrappedValue = newImage
            }
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
    /// Takes a screenshot when this view appears and passes it via the `image` binding.
    public func screenshotOnAppear(to image: Binding<UIImage?>) -> some View {
        TakeSnapshotView(image: image, rootView: self)
    }
    
    @available(iOS, deprecated: 13.0, renamed: "screenshotOnAppear(to:)")
    public func snapshot(to image: Binding<UIImage?>) -> some View {
        screenshotOnAppear(to: image)
    }
}

#endif
